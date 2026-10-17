import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;
import 'local_store.dart';

Future<List<int>> derivePassword(
  String password,
  List<int> salt,
  int rounds,
) async {
  if (!web.window.isSecureContext) {
    throw const AppException(
      'Abre Inventi en localhost o mediante HTTPS para iniciar sesión o crear una cuenta.',
    );
  }
  final subtle = web.window.crypto.subtle;
  final key = await subtle
      .importKey(
        'raw',
        Uint8List.fromList(utf8.encode(password)).toJS,
        'PBKDF2'.toJS,
        false,
        ['deriveBits'.toJS].toJS,
      )
      .toDart;
  final bits = await subtle
      .deriveBits(
        _Pbkdf2Params(
          name: 'PBKDF2',
          salt: Uint8List.fromList(salt).toJS,
          iterations: rounds,
          hash: 'SHA-256'.toJS,
        ),
        key,
        256,
      )
      .toDart;
  return bits.toDart.asUint8List();
}

extension type _Pbkdf2Params._(JSObject _) implements JSObject {
  external factory _Pbkdf2Params({
    required String name,
    required JSUint8Array salt,
    required int iterations,
    required JSString hash,
  });
}
