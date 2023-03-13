import 'dart:io';
import "package:path/path.dart" show dirname;

final thisDir = dirname(Platform.script.path);

Future<bool> cmdAvailable(String cmd) async {
  final result = await Process.run(cmd, ["--version"]);
  final out = result.stdout as String;
  return out.toLowerCase().startsWith(cmd);
}

/// Determine if podman is available, if not try docker
Future<String> getDockerCmd() async {

  if (await cmdAvailable("podman")) {
    return "podman";
  } else if (await cmdAvailable("docker")) {
    return "docker";
  } else {
    print("Could not find podman or docker to use for wasm build");
    exit(1);
  }

}

Future<int> execWithStdio(
  String executable,
  List<String> arguments,
) async {

  final process = await Process.start(
    executable, arguments, mode: ProcessStartMode.inheritStdio,
  );

  return await process.exitCode;

}

/// Runs the [dockerfile], binding [bindDir] to /host in the container and
/// running [containerCmd]
Future<bool> dockerRun(
  String dockerCmd, String dockerfile, String tag, String bindDir,
  String containerCmd,
) async {

  // Build
  print("Building $dockerfile using tag $tag");
  var exitCode = await execWithStdio(
    dockerCmd, ["build", "-f", "$thisDir/$dockerfile", "-t", tag],
  );

  if (exitCode != 0) {
    print("Build of $tag failed");
    return false;
  }

  // Run
  print("Running $containerCmd");
  exitCode = await execWithStdio(
    dockerCmd, ["run", "--volume", "$bindDir:/host", tag, "bash", "-c", containerCmd],
  );

  if (exitCode != 0) {
    print("Execution of $tag failed");
    return false;
  }

  print("Execution of $tag succeeded. It may be removed from the image store if desired");

  return true;

}

/// Runs the docker container and copies the [internalFile] to the build
/// directory
Future<bool> dockerBuild(
  String dockerCmd, String dockerfile, String tag, String internalFile,
) async {

  // Ensure build directory is created
  final buildDir = "$thisDir/../build";
  Directory(buildDir).create();

  return dockerRun(
    dockerCmd, dockerfile, tag, buildDir, "cp $internalFile /host/",
  );

}
