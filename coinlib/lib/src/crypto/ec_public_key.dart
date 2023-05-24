import 'dart:typed_data';
import 'package:coinlib/src/bindings/secp256k1.dart';
import 'package:coinlib/src/common/bytes.dart';
import 'package:coinlib/src/common/hex.dart';
import 'package:collection/collection.dart';

class InvalidPublicKey implements Exception {}

/// Represents an ECC public key on the secp256k1 curve that has an associated
/// private key
class ECPublicKey {

  /// Either 33 compressed or 65 uncompressed bytes
  final Uint8List data;

  /// Constructs a public key from a 33-byte compressed or 65-byte uncompressed
  /// representation. [InvalidPublicKey] will be thrown if the public key is
  /// invalid or in the wrong format.
  ECPublicKey(this.data) {
    if (data.length != 33 && data.length != 65) {
      throw ArgumentError(
        "Public keys should be 33 or 65 bytes", "this.data",
      );
    }
    if (!secp256k1.pubKeyVerify(data)) throw InvalidPublicKey();
  }

  /// Constructs a public key from HEX encoded data that must represent a
  /// 33-byte compressed key, or 65-byte uncompressed key
  ECPublicKey.fromHex(String hex) : this(hexToBytes(hex));

  get hex => bytesToHex(data);
  get compressed => data.length == 33;

  @override
  bool operator ==(Object other)
    => (other is ECPublicKey) && ListEquality().equals(data, other.data);

  @override
  int get hashCode => data[1] | data[2] << 8 | data[3] << 16 | data[4] << 24;

  /// Tweaks the public key with a scalar multiplied by the generator point. In
  /// the instance a new key cannot be created (practically impossible for
  /// random 32-bit scalars), then null will be returned.
  ECPublicKey? tweak(Uint8List scalar) {
    checkBytes(scalar, 32, name: "Scalar");
    final newKey = secp256k1.pubKeyTweak(data, scalar, compressed);
    return newKey == null ? null : ECPublicKey(newKey);
  }

}
