import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:inventi/services/image_service.dart';
import 'package:inventi/services/local_store.dart';
import 'helpers.dart';

const tinyPng =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGP4////fwAJ+wP9KobjigAAAABJRU5ErkJggg==';
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'Rechaza archivos vacíos, no imagen e imágenes de más de 512 KB',
    () async {
      for (final bytes in [
        Uint8List(0),
        Uint8List.fromList([1, 2, 3]),
        Uint8List(ImageService.maxBytes + 1),
      ]) {
        await expectLater(
          ImageService.validateAndEncode(bytes),
          throwsA(isA<AppException>()),
        );
      }
    },
  );
  test('Guarda bytes de imagen y los conserva al recargar', () async {
    final encoded = await ImageService.validateAndEncode(base64Decode(tinyPng));
    final store = MemoryStore();
    final controller = makeController(store);
    await controller.initialize();
    await registerUser(controller);
    await controller.login('ana@example.com', 'Prueba123!');
    await saveExample(controller, image: encoded);
    final restored = makeController(store);
    await restored.initialize();
    expect(restored.products.last.imageBase64, tinyPng);
    expect(restored.products.last.toJson().containsKey('imagePath'), isFalse);
    await saveExample(restored, id: restored.products.last.id);
    expect(restored.products.last.imageBase64, isNull);
    controller.dispose();
    restored.dispose();
  });

  test('Rechaza imágenes que superan las dimensiones permitidas', () async {
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder).drawColor(const ui.Color(0xFFFFFFFF), ui.BlendMode.src);
    final picture = recorder.endRecording();
    final image = await picture.toImage(4097, 1);
    final bytes = (await image.toByteData(
      format: ui.ImageByteFormat.png,
    ))!.buffer.asUint8List();
    await expectLater(
      ImageService.validateAndEncode(bytes),
      throwsA(isA<AppException>()),
    );
    image.dispose();
    picture.dispose();
  });
}
