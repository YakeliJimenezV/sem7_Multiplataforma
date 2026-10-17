import 'dart:convert';
import 'dart:math';
import 'pbkdf2_native.dart'
    if (dart.library.js_interop) 'pbkdf2_web.dart'
    as platform;

class PasswordService {
  PasswordService({this.iterations = 600000});
  final int iterations;
  final Random _random = Random.secure();

  String newId() => base64UrlEncode(
    List<int>.generate(24, (_) => _random.nextInt(256)),
  ).replaceAll('=', '');
  String newSalt() =>
      base64Encode(List<int>.generate(16, (_) => _random.nextInt(256)));

  Future<String> hash(String password, String salt, {int? rounds}) async {
    return base64Encode(
      await platform.derivePassword(
        password,
        base64Decode(salt),
        rounds ?? iterations,
      ),
    );
  }

  Future<bool> verify(
    String password,
    String salt,
    String expected,
    int rounds,
  ) async {
    final actualBytes = base64Decode(
      await hash(password, salt, rounds: rounds),
    );
    final expectedBytes = base64Decode(expected);
    if (actualBytes.length != expectedBytes.length) return false;
    var difference = 0;
    for (var i = 0; i < actualBytes.length; i++) {
      difference |= actualBytes[i] ^ expectedBytes[i];
    }
    return difference == 0;
  }
}
