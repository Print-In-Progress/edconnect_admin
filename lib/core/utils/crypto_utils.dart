import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:pointycastle/export.dart' as pc;

Uint8List bigIntToBytes(BigInt number) {
  // Convert BigInt to a hexadecimal string
  var hexString = number.toRadixString(16);
  if (hexString.length % 2 != 0) {
    hexString = '0$hexString';
  }

  // Convert hex string to byte array
  var bytes = Uint8List.fromList(List<int>.generate(hexString.length ~/ 2,
      (i) => int.parse(hexString.substring(i * 2, i * 2 + 2), radix: 16)));

  return bytes;
}

String convertPublicKeyToPem(pc.RSAPublicKey publicKey) {
  // Convert the public key components to bytes
  Uint8List publicKeyBytes = bigIntToBytes(publicKey.modulus!);

  // Encode the bytes to Base64
  String publicKeyBase64 = base64Encode(publicKeyBytes);

  // Format it as a PEM string
  final pem =
      '-----BEGIN PUBLIC KEY-----\n$publicKeyBase64\n-----END PUBLIC KEY-----';
  return pem;
}

// Add this function to convert PEM string back to RSAPublicKey
pc.RSAPublicKey convertPemToPublicKey(String pemString) {
  // Remove header and footer and whitespace
  final pemContent = pemString
      .replaceAll('-----BEGIN PUBLIC KEY-----', '')
      .replaceAll('-----END PUBLIC KEY-----', '')
      .replaceAll('\n', '');

  // Decode base64
  final publicKeyBytes = base64Decode(pemContent);

  // This is a simplified approach PEM Format just encodes the modulus might need to parse ASN.1 for more complex keys
  final modulus = decodeBigInt(publicKeyBytes);
  final exponent = BigInt.from(65537);

  return pc.RSAPublicKey(modulus, exponent);
}

// Helper function to decode BigInt from bytes
BigInt decodeBigInt(List<int> bytes) {
  BigInt result = BigInt.from(0);
  for (int i = 0; i < bytes.length; i++) {
    result += BigInt.from(bytes[i]) << (8 * (bytes.length - i - 1));
  }
  return result;
}

String generatePublicKeyFingerprint(pc.RSAPublicKey publicKey) {
  // Extract the public key bytes
  var modulusBytes = bigIntToBytes(publicKey.modulus!);
  var exponentBytes = bigIntToBytes(publicKey.exponent!);

  var publicKeyBytes =
      Uint8List(modulusBytes.length + exponentBytes.length + 8);
  var buffer = ByteData.sublistView(publicKeyBytes);

  buffer.setUint32(0, modulusBytes.length, Endian.big);
  buffer.setUint32(4, exponentBytes.length, Endian.big);
  publicKeyBytes.setRange(8, 8 + modulusBytes.length, modulusBytes);
  publicKeyBytes.setRange(
      8 + modulusBytes.length, publicKeyBytes.length, exponentBytes);

  // Compute the SHA-256 hash of the public key bytes
  var hash = hashBytes(publicKeyBytes);

  return hash;
}

String hashBytes(Uint8List bytes) {
  var digest = sha256.convert(bytes);
  return digest.toString();
}

pc.AsymmetricKeyPair<pc.RSAPublicKey, pc.RSAPrivateKey> generateRSAKeyPair() {
  var keyParams = pc.RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64);
  var secureRandom = pc.FortunaRandom();

  var random = Uint8List(32);
  for (int i = 0; i < random.length; i++) {
    random[i] = i + 1;
  }
  secureRandom.seed(pc.KeyParameter(random));

  var rngParams = pc.ParametersWithRandom(keyParams, secureRandom);
  var keyGenerator = pc.RSAKeyGenerator();
  keyGenerator.init(rngParams);

  // Generate the key pair
  var pair = keyGenerator.generateKeyPair();

  // Manually cast the keys to the correct types
  final pc.RSAPublicKey publicKey = pair.publicKey as pc.RSAPublicKey;
  final pc.RSAPrivateKey privateKey = pair.privateKey as pc.RSAPrivateKey;

  return pc.AsymmetricKeyPair<pc.RSAPublicKey, pc.RSAPrivateKey>(
      publicKey, privateKey);
}

Uint8List signHash(String hash, pc.RSAPrivateKey privateKey) {
  var signer = pc.Signer("SHA-256/RSA");
  signer.init(true, pc.PrivateKeyParameter<pc.RSAPrivateKey>(privateKey));
  var signature =
      signer.generateSignature(Uint8List.fromList(utf8.encode(hash)))
          as pc.RSASignature;
  return signature.bytes;
}

bool verifySignature(
    String hash, Uint8List signatureBytes, pc.RSAPublicKey publicKey) {
  var signer = pc.Signer("SHA-256/RSA");
  signer.init(false, pc.PublicKeyParameter<pc.RSAPublicKey>(publicKey));
  var signature = pc.RSASignature(signatureBytes);
  return signer.verifySignature(
      Uint8List.fromList(utf8.encode(hash)), signature);
}
