import 'package:coinlib/src/common/hex.dart';
import 'package:test/test.dart';
import 'package:coinlib/coinlib.dart';
import 'common.dart';

class ScriptVector {
  final String inputAsm;
  final String inputHex;
  final String? outputAsm;
  final String? outputHex;
  ScriptVector({
    required this.inputAsm,
    required this.inputHex,
    this.outputAsm,
    this.outputHex,
  });
}

final vectors = [
  // Basic scripts
  ScriptVector(inputAsm: "0", inputHex: "00"),
  ScriptVector(inputAsm: "0 0", inputHex: "0000"),
  ScriptVector(
    inputAsm: "01 0 -1 OP_DUP 0102030405 57c74942 0000",
    inputHex: "51004f760501020304050457c74942020000",
  ),
  // Alternative ASM
  ScriptVector(
    inputAsm: "00 f OP_1NEGATE OP_NOP2 102030405 OP_FALSE",
    outputAsm: "0 0f -1 OP_CHECKLOCKTIMEVERIFY 0102030405 0",
    inputHex: "005f4fb105010203040500",
  ),
  // Non-compressed pushdata
  ScriptVector(
    inputAsm: "0 0 0102030405",
    inputHex: "01004c004e050000000102030405",
    outputHex: "0000050102030405",
  ),
];

void main() {

  group("Script", () {

    test("valid script vectors", () {
      for (final vec in vectors) {

        final fromAsm = Script.fromASM(vec.inputAsm);
        final fromHex = Script.decompile(hexToBytes(vec.inputHex));

        for (final script in [fromAsm, fromHex]) {

          final expectAsm = vec.outputAsm ?? vec.inputAsm;
          final expectHex = vec.outputHex ?? vec.inputHex;
          expect(script.asm, expectAsm);
          expect(bytesToHex(script.compiled), expectHex);

          // Mutation of script not allowed
          script.compiled[0] = 0xff;
          expect(bytesToHex(script.compiled), expectHex);

        }

      }
    });

    test("requireMinimal fails when not minimal", () {
      expect(Script.decompile(hexToBytes("00")), isA<Script>());
      expect(
        () => Script.decompile(hexToBytes("0100"), requireMinimal: true),
        throwsA(isA<PushDataNotMinimal>()),
      );
    });

    test("gives immutable ops as expected", () {

      final script = Script.fromASM("01 0 -1 OP_NOP2 0102030405 57c74942");
      expect(script.ops.length, 6);

      expectScriptOp(script.ops[0], "01", "51", 1, false);
      expectScriptOp(script.ops[1], "0", "00", 0, false);
      expectScriptOp(script.ops[2], "-1", "4f", -1, false);
      expectScriptOp(script.ops[3], "OP_CHECKLOCKTIMEVERIFY", "b1", null, false);
      expectScriptOp(script.ops[4], "0102030405", "050102030405", null, true);
      expectScriptOp(script.ops[5], "57c74942", "0457c74942", 0x4249c757, true);

      // Immutable
      expect(() => script.ops[0] = ScriptOpCode(0), throwsA(anything));

    });

    test("invalid asm", () {
      for (final invalid in [
        "", " ", "0 ", " 0", "0 op_dup", "0 OP_DUP ", "0  OP_DUP", "0 DUP",
      ]) {
        expect(() => Script.fromASM(invalid), throwsA(isA<InvalidScriptAsm>()));
      }
    });

  });

}