import 'dart:typed_data';
import 'package:coinlib/coinlib.dart';
import 'package:test/test.dart';
import '../../vectors/tx.dart';

signatureHasherTester(
  String name,
  Uint8List Function(Transaction tx, int inputN, SigHashVector vec) hasher,
  String Function(SigHashVector vec) hashFromVec,
) => group(name, () {

  late Transaction tx;
  setUpAll(() async {
    await loadCoinlib();
    tx = Transaction.fromHex(sigHashTxHex);
  });

  test("produces correct signature hash", () {
    for (final vec in sighashVectors) {
      expect(bytesToHex(hasher(tx, vec.inputN, vec)), hashFromVec(vec));
    }
  });

  test("input out of range", () {
    expect(() => hasher(tx, 2, sighashVectors[0]), throwsArgumentError);
  });

});
