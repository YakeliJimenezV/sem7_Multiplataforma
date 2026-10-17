import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventi/services/password_service.dart';

void main() {
  // Vectores conocidos de PBKDF2-HMAC-SHA256; también se ejecutan con Web Crypto.
  for (final vector in [
    (1, '120fb6cffcf8b32c43e7225256c4f837a86548c92ccc35480805987cb70be17b'),
    (2, 'ae4d0c95af6b46d32d0adff928f06dd02a303f8ef3c251dfd6e2d85a95474c43'),
    (4096, 'c5e478d59288c841aa530db6845c4c8d962893a001ce4e11a4963873aa98134a'),
  ]) {
    test('PBKDF2-SHA256 vector de ${vector.$1} iteraciones', () async {
      final service = PasswordService(iterations: vector.$1);
      final hash = await service.hash(
        'password',
        base64Encode(utf8.encode('salt')),
      );
      final hex = base64Decode(
        hash,
      ).map((v) => v.toRadixString(16).padLeft(2, '0')).join();
      expect(hex, vector.$2);
    });
  }
}
