import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;
import 'local_store.dart';

Future<Uint8List?> pickImage(int maxBytes) {
  final completer = Completer<Uint8List?>();
  final input = web.HTMLInputElement()
    ..type = 'file'
    ..accept = 'image/png,image/jpeg,image/webp';
  input.style.display = 'none';
  void finish(Uint8List? bytes, [Object? error]) {
    if (completer.isCompleted) return;
    input.remove();
    if (error != null) {
      completer.completeError(error);
    } else {
      completer.complete(bytes);
    }
  }

  input.addEventListener('cancel', ((web.Event event) => finish(null)).toJS);
  input.addEventListener(
    'change',
    ((web.Event event) {
      final files = input.files;
      if (files == null || files.length == 0) {
        finish(null);
        return;
      }
      final file = files.item(0)!;
      if (file.size > maxBytes) {
        finish(
          null,
          const AppException('La imagen debe pesar como máximo 512 KB.'),
        );
        return;
      }
      file.arrayBuffer().toDart.then(
        (buffer) => finish(buffer.toDart.asUint8List()),
        onError: (Object error) =>
            finish(null, const AppException('No se pudo leer la imagen.')),
      );
    }).toJS,
  );
  web.document.body!.appendChild(input);
  input.click();
  return completer.future;
}
