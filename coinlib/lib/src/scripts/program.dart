import 'dart:typed_data';
import 'programs/p2pkh.dart';
import 'script.dart';

/// Thrown when a script doesn't match the program being constructed
class NoProgramMatch implements Exception {}

/// An interface for programs that wrap a [Script] with associated
/// functionality.
abstract class Program {

  Script get script;

  /// Takes a [script] and constructs a matching Program ubclass if one exists,
  /// or a basic [RawProgram] if there is no match. The script should use
  /// minimal pushes. [decompile] can be used directly on compiled scripts or
  /// [fromASM] can be used to match directly against ASM.
  factory Program.match(Script script) {

    try {
      return P2PKH.fromScript(script);
    } on NoProgramMatch catch(_) {}

    // If nothing matched, return a raw program
    return RawProgram(script);

  }

  factory Program.decompile(Uint8List script)
    => Program.match(Script.decompile(script));

  factory Program.fromAsm(String asm) => Program.match(Script.fromAsm(asm));

}

/// A program that is not recognised and merely wraps a [Script].
class RawProgram implements Program {
  @override
  final Script script;
  RawProgram(this.script);
}
