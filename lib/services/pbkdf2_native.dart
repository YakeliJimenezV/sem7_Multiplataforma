import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

Future<List<int>> derivePassword(String password, List<int> salt, int rounds) =>
    compute(_derive, (password, salt, rounds));

// RFC 8018 §5.2: PBKDF2-HMAC-SHA256, un bloque de salida de 256 bits.
// Se ejecuta en un isolate en plataformas nativas para no bloquear la interfaz.
List<int> _derive((String, List<int>, int) input) {
  if (input.$3 < 1) throw ArgumentError('Iterations must be positive');
  final hmac = Hmac(sha256, utf8.encode(input.$1));
  var previous = hmac.convert([...input.$2, 0, 0, 0, 1]).bytes;
  final output = Uint8List.fromList(previous);
  for (var i = 1; i < input.$3; i++) {
    previous = hmac.convert(previous).bytes;
    for (var j = 0; j < output.length; j++) {
      output[j] ^= previous[j];
    }
  }
  return output;
}
