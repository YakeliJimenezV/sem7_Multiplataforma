import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'image_picker_stub.dart'
    if (dart.library.js_interop) 'image_picker_web.dart'
    as platform;
import 'local_store.dart';

class ImageService {
  static const maxBytes = 512 * 1024;
  Future<String?> pick() async {
    final bytes = await platform.pickImage(maxBytes);
    return bytes == null ? null : validateAndEncode(bytes);
  }

  static Future<String> validateAndEncode(Uint8List bytes) async {
    if (bytes.isEmpty || bytes.length > maxBytes) {
      throw const AppException('Selecciona una imagen de hasta 512 KB.');
    }
    final png =
        bytes.length >= 8 &&
        bytes[0] == 137 &&
        bytes[1] == 80 &&
        bytes[2] == 78 &&
        bytes[3] == 71;
    final jpg =
        bytes.length >= 3 &&
        bytes[0] == 255 &&
        bytes[1] == 216 &&
        bytes[2] == 255;
    final webp =
        bytes.length >= 12 &&
        ascii.decode(bytes.sublist(0, 4), allowInvalid: true) == 'RIFF' &&
        ascii.decode(bytes.sublist(8, 12), allowInvalid: true) == 'WEBP';
    if (!png && !jpg && !webp) {
      throw const AppException('Usa una imagen PNG, JPG o WebP válida.');
    }
    try {
      // ImageDescriptor.width/height no están disponibles en Flutter Web 3.35.
      // Decodificamos un frame con un límite de recursos y leemos su tamaño.
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: 4097,
        targetHeight: 4097,
        allowUpscaling: false,
      );
      try {
        final frame = await codec.getNextFrame();
        try {
          if (frame.image.width > 4096 || frame.image.height > 4096) {
            throw const AppException(
              'La imagen no debe superar 4096 × 4096 píxeles.',
            );
          }
        } finally {
          frame.image.dispose();
        }
      } finally {
        codec.dispose();
      }
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException('No se pudo leer la imagen. Prueba con otra.');
    }
    return base64Encode(bytes);
  }
}
