import 'dart:typed_data';
import 'package:coinlib/src/scripts/operations.dart';
import 'package:coinlib/src/scripts/program.dart';
import 'package:coinlib/src/scripts/script.dart';

/// Arbitrary witness program
class P2Witness implements Program {

  @override
  final Script script;
  late final int version;
  late final Uint8List _program;

  bool _programSizeOk(int size) => size >= 2 && size <= 40;

  P2Witness.fromScript(this.script) {

    if (
      script.ops.length != 2
      || script[0] is! ScriptOpCode
      || script[1] is! ScriptPushData
    ) throw NoProgramMatch();

    final ver = (script[0] as ScriptOpCode).number;
    final push = script[1] as ScriptPushData;

    if (ver == null || ver < 0 || ver > 16 || !_programSizeOk(push.data.length)) {
      throw NoProgramMatch();
    }

    _program = push.data;
    version = ver;

  }

  P2Witness.decompile(Uint8List compiled)
    : this.fromScript(Script.decompile(compiled));

  P2Witness.fromAsm(String asm) : this.fromScript(Script.fromAsm(asm));

  P2Witness.fromProgram(this.version, Uint8List program)
    : _program = Uint8List.fromList(program),
    script = Script([
      ScriptOp.fromNumber(version), ScriptPushData(program),
    ]) {
    if (version < 0 || version > 16 || !_programSizeOk(program.length)) {
      throw ArgumentError.value(program, "this.program", "wrong size");
    }
  }

  Uint8List get program => Uint8List.fromList(_program);

}
