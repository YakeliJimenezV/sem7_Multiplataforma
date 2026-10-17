import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventi/providers/inventory_controller.dart';
import 'package:inventi/services/local_store.dart';
import 'package:inventi/services/password_service.dart';
import 'helpers.dart';

void main() {
  late MemoryStore store;
  late InventoryController controller;
  setUp(() async {
    store = MemoryStore();
    controller = makeController(store);
    await controller.initialize();
  });
  tearDown(() {
    controller.dispose();
  });

  test(
    'Registro normaliza correo, no inicia sesión y no guarda la contraseña',
    () async {
      await registerUser(controller, email: ' ANA@Example.com ');
      expect(controller.authenticated, isFalse);
      final json = jsonDecode(store.value!) as Map<String, dynamic>;
      final account = (json['users'] as List).single as Map<String, dynamic>;
      expect(account['email'], 'ana@example.com');
      expect(account['salt'], isNotEmpty);
      expect(account['passwordHash'], isNot('Prueba123!'));
      expect(store.value, isNot(contains('Prueba123!')));
      await controller.login('ana@example.com', 'Prueba123!');
      expect(controller.products.map((p) => p.name), [
        'Laptop',
        'Mouse',
        'Teclado',
        'Monitor',
      ]);
      expect(controller.products.map((p) => p.priceCents), [
        350000,
        5000,
        12000,
        80000,
      ]);
      expect(controller.totalUnits, 58);
      expect(controller.totalValueCents, 4445000);
      expect(controller.products.map((p) => p.id).toSet().length, 4);
    },
  );
  test('Impide correos duplicados sin distinguir mayúsculas', () async {
    await registerUser(controller);
    await expectLater(
      registerUser(controller, email: ' ANA@EXAMPLE.COM '),
      throwsA(isA<AppException>()),
    );
    expect((jsonDecode(store.value!)['users'] as List).length, 1);
  });
  test('Registro inválido no escribe nada', () async {
    await expectLater(
      controller.register(
        name: '',
        email: 'incorrecto',
        phone: '1',
        password: '123',
        confirmation: '321',
      ),
      throwsA(isA<AppException>()),
    );
    expect(store.value, isNull);
  });
  test(
    'Credenciales incorrectas y correo inexistente no abren sesión',
    () async {
      await registerUser(controller);
      for (final email in ['ana@example.com', 'nadie@example.com']) {
        await expectLater(
          controller.login(email, 'Incorrecta123!'),
          throwsA(isA<AppException>()),
        );
        expect(controller.authenticated, isFalse);
      }
    },
  );
  test(
    'Sesión, perfil y productos se restauran desde almacenamiento',
    () async {
      await registerUser(controller);
      await controller.login('ana@example.com', 'Prueba123!');
      await controller.updateProfile('Ana María', '+51 900 100 200');
      await saveExample(controller);
      final restored = makeController(store);
      await restored.initialize();
      expect(restored.authenticated, isTrue);
      expect(restored.user!.name, 'Ana María');
      expect(restored.user!.phone, '+51 900 100 200');
      expect(restored.products.length, 5);
      await restored.logout();
      restored.dispose();
      final signedOut = makeController(store);
      await signedOut.initialize();
      expect(signedOut.authenticated, isFalse);
      expect(signedOut.products, isEmpty);
      signedOut.dispose();
    },
  );
  test('CRUD actualiza inventario, estadísticas y persistencia', () async {
    await registerUser(controller);
    await controller.login('ana@example.com', 'Prueba123!');
    await saveExample(controller);
    final product = controller.products.last;
    expect(product.priceCents, 1990);
    expect(controller.totalUnits, 62);
    await saveExample(
      controller,
      id: product.id,
      name: 'Libreta grande',
      price: '25,50',
      stock: '2',
    );
    expect(controller.products.length, 5);
    expect(controller.productById(product.id)!.priceCents, 2550);
    await controller.deleteProduct(product.id);
    expect(controller.productById(product.id), isNull);
    expect(controller.totalUnits, 58);
    final restored = makeController(store);
    await restored.initialize();
    expect(restored.products.length, 4);
    restored.dispose();
  });
  test(
    'Productos y perfil aislados por usuario, incluso con ID ajeno',
    () async {
      await registerUser(controller);
      await controller.login('ana@example.com', 'Prueba123!');
      await saveExample(controller);
      final foreignId = controller.products.last.id;
      await controller.logout();
      await registerUser(controller, email: 'luis@example.com', name: 'Luis');
      await controller.login('luis@example.com', 'Prueba123!');
      expect(controller.user!.name, 'Luis');
      expect(controller.products.length, 4);
      expect(controller.productById(foreignId), isNull);
      await expectLater(
        saveExample(controller, id: foreignId),
        throwsA(isA<AppException>()),
      );
      await expectLater(
        controller.deleteProduct(foreignId),
        throwsA(isA<AppException>()),
      );
      await controller.updateProfile('Luis Pérez', '900000000');
      await controller.logout();
      await controller.login('ana@example.com', 'Prueba123!');
      expect(controller.user!.name, 'Ana Torres');
      expect(controller.products.length, 5);
    },
  );
  test('Rechaza CRUD y perfil sin sesión', () async {
    await expectLater(saveExample(controller), throwsA(isA<AppException>()));
    await expectLater(
      controller.deleteProduct('id'),
      throwsA(isA<AppException>()),
    );
    await expectLater(
      controller.updateProfile('Intruso', '999888777'),
      throwsA(isA<AppException>()),
    );
  });
  test(
    'Rechaza stock, precio y categoría inválidos en la capa de estado',
    () async {
      await registerUser(controller);
      await controller.login('ana@example.com', 'Prueba123!');
      await expectLater(
        saveExample(controller, price: '-1'),
        throwsA(isA<AppException>()),
      );
      await expectLater(
        saveExample(controller, stock: '1.5'),
        throwsA(isA<AppException>()),
      );
      await expectLater(
        saveExample(controller, category: 'Inexistente'),
        throwsA(isA<AppException>()),
      );
      expect(controller.products.length, 4);
    },
  );
  test(
    'Fallo de escritura revierte productos, perfil y cierre de sesión',
    () async {
      await registerUser(controller);
      await controller.login('ana@example.com', 'Prueba123!');
      final original = store.value;
      store.failWrite = true;
      await expectLater(saveExample(controller), throwsA(isA<AppException>()));
      await expectLater(
        controller.deleteProduct(controller.products.first.id),
        throwsA(isA<AppException>()),
      );
      await expectLater(
        controller.updateProfile('Otro', '999888777'),
        throwsA(isA<AppException>()),
      );
      await expectLater(controller.logout(), throwsA(isA<AppException>()));
      expect(controller.products.length, 4);
      expect(controller.user!.name, 'Ana Torres');
      expect(controller.authenticated, isTrue);
      expect(store.value, original);
      expect(controller.busy, isFalse);
    },
  );
  test('Fallo de registro o login no altera cuentas ni sesión', () async {
    store.failWrite = true;
    await expectLater(registerUser(controller), throwsA(isA<AppException>()));
    expect(store.value, isNull);
    store.failWrite = false;
    await registerUser(controller);
    store.failWrite = true;
    await expectLater(
      controller.login('ana@example.com', 'Prueba123!'),
      throwsA(isA<AppException>()),
    );
    expect(controller.authenticated, isFalse);
  });
  test('Datos corruptos no se sobrescriben y se puede reintentar', () async {
    store.value = '{corrupto';
    await controller.initialize();
    expect(controller.ready, isFalse);
    expect(controller.initializationError, isNotNull);
    await expectLater(registerUser(controller), throwsA(isA<AppException>()));
    expect(store.value, '{corrupto');
    store.value = null;
    await controller.initialize();
    expect(controller.ready, isTrue);
  });
  test(
    'Errores de lectura y versiones desconocidas se muestran sin borrar datos',
    () async {
      store.failRead = true;
      await controller.initialize();
      expect(controller.initializationError, isNotNull);
      store.failRead = false;
      store.value = '{"version":2}';
      await controller.initialize();
      expect(controller.ready, isFalse);
      expect(store.value, '{"version":2}');
    },
  );
  test('Identificador de sesión inexistente no autentica', () async {
    await registerUser(controller);
    final json = jsonDecode(store.value!) as Map<String, dynamic>;
    json['sessionId'] = 'inexistente';
    store.value = jsonEncode(json);
    await controller.initialize();
    expect(controller.authenticated, isFalse);
  });

  test(
    'Datos con propietarios inválidos o correos duplicados no se cargan',
    () async {
      await registerUser(controller);
      final original = store.value!;
      final invalidOwner = jsonDecode(original) as Map<String, dynamic>;
      (invalidOwner['products'] as List).first['ownerId'] = 'ajeno';
      store.value = jsonEncode(invalidOwner);
      await controller.initialize();
      expect(controller.ready, isFalse);
      expect(controller.initializationError, isNotNull);
      final duplicated = jsonDecode(original) as Map<String, dynamic>;
      final users = duplicated['users'] as List;
      users.add({...users.first as Map<String, dynamic>, 'id': 'otro-id'});
      store.value = jsonEncode(duplicated);
      await controller.initialize();
      expect(controller.ready, isFalse);
    },
  );
  test(
    'PBKDF2 usa sal aleatoria, verifica y tiene 600000 rondas por defecto',
    () async {
      expect(PasswordService().iterations, 600000);
      final service = PasswordService(iterations: 1000);
      final salt = service.newSalt();
      expect(base64Decode(salt).length, 16);
      final hash = await service.hash('Contraseña123', salt);
      expect(base64Decode(hash).length, 32);
      expect(await service.verify('Contraseña123', salt, hash, 1000), isTrue);
      expect(await service.verify('OtraClave123', salt, hash, 1000), isFalse);
      expect(
        await service.hash('Contraseña123', service.newSalt()),
        isNot(hash),
      );
    },
  );
}
