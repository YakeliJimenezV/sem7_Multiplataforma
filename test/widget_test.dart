import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventi/app.dart';
import 'package:inventi/router.dart';
import 'package:inventi/providers/inventory_controller.dart';
import 'helpers.dart';

Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.runAsync(() async {
    await tester.tap(finder);
    await Future<void>.delayed(const Duration(milliseconds: 70));
  });
  await tester.pumpAndSettle();
}

void viewport(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> mount(
  WidgetTester tester,
  InventoryController controller, {
  String location = '/dashboard',
}) async {
  await tester.pumpWidget(
    InventiApp(controller: controller, initialLocation: location),
  );
  await tester.pumpAndSettle();
}

void main() {
  late InventoryController controller;
  setUp(() async {
    controller = makeController(MemoryStore());
    await controller.initialize();
  });
  tearDown(() {
    controller.dispose();
  });

  testWidgets('Registro, login, errores y mostrar contraseña en escritorio', (
    tester,
  ) async {
    viewport(tester, const Size(1440, 1000));
    await mount(tester, controller);
    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
    await tapAndSettle(tester, find.byKey(const Key('login-submit')));
    expect(find.text('Este campo es obligatorio.'), findsOneWidget);
    await tapAndSettle(tester, find.text('Regístrate'));
    await tester.enterText(
      find.byKey(const Key('register-name')),
      'Ana Torres',
    );
    await tester.enterText(
      find.byKey(const Key('register-email')),
      'ana@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('register-phone')),
      '999888777',
    );
    await tester.enterText(
      find.byKey(const Key('register-password')),
      'Prueba123!',
    );
    await tester.enterText(
      find.byKey(const Key('register-confirmation')),
      'Prueba123!',
    );
    await tapAndSettle(tester, find.byKey(const Key('register-submit')));
    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('login-email')),
      'ana@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('login-password')),
      'Incorrecta123!',
    );
    await tapAndSettle(tester, find.byKey(const Key('login-submit')));
    expect(find.text('Correo o contraseña incorrectos.'), findsOneWidget);
    await tapAndSettle(tester, find.byTooltip('Mostrar contraseña'));
    final field = tester.widget<TextFormField>(
      find.descendant(
        of: find.byKey(const Key('login-password')),
        matching: find.byType(TextFormField),
      ),
    );
    expect(field, isNotNull);
    expect(
      tester
          .widget<TextField>(
            find.descendant(
              of: find.byKey(const Key('login-password')),
              matching: find.byType(TextField),
            ),
          )
          .obscureText,
      isFalse,
    );
    await tester.enterText(
      find.byKey(const Key('login-password')),
      'Prueba123!',
    );
    await tapAndSettle(tester, find.byKey(const Key('login-submit')));
    expect(find.text('Hola, Ana 👋'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Crear, buscar, filtrar, editar y eliminar con confirmación', (
    tester,
  ) async {
    viewport(tester, const Size(1440, 1050));
    await tester.runAsync(() async {
      await registerUser(controller);
      await controller.login('ana@example.com', 'Prueba123!');
    });
    await mount(tester, controller, location: '/products/new');
    await tester.enterText(find.byKey(const Key('product-name')), 'Libreta');
    await tester.enterText(
      find.byKey(const Key('product-description')),
      'Libreta de notas',
    );
    await tester.enterText(find.byKey(const Key('product-price')), '-2');
    await tester.enterText(find.byKey(const Key('product-stock')), '3.5');
    await tapAndSettle(tester, find.byKey(const Key('product-save')));
    expect(controller.products.length, 4);
    await tester.enterText(find.byKey(const Key('product-price')), '19,90');
    await tester.enterText(find.byKey(const Key('product-stock')), '4');
    await tapAndSettle(tester, find.byKey(const Key('product-category')));
    await tapAndSettle(tester, find.text('Oficina').last);
    await tapAndSettle(tester, find.byKey(const Key('product-save')));
    expect(controller.products.length, 5);
    await tester.enterText(find.byKey(const Key('product-search')), 'LIBRE');
    await tester.pumpAndSettle();
    expect(find.text('Libreta'), findsOneWidget);
    expect(find.text('Laptop'), findsNothing);
    await tapAndSettle(tester, find.widgetWithText(ChoiceChip, 'Hogar'));
    expect(find.text('No encontramos productos'), findsOneWidget);
    await tapAndSettle(tester, find.widgetWithText(ChoiceChip, 'Oficina'));
    expect(find.text('Libreta'), findsOneWidget);
    await tapAndSettle(tester, find.text('Editar'));
    await tester.enterText(
      find.byKey(const Key('product-name')),
      'Libreta grande',
    );
    await tapAndSettle(tester, find.byKey(const Key('product-save')));
    expect(controller.products.last.name, 'Libreta grande');
    await tapAndSettle(tester, find.byTooltip('Eliminar Libreta grande'));
    await tapAndSettle(tester, find.text('Cancelar'));
    expect(controller.products.length, 5);
    await tapAndSettle(tester, find.byTooltip('Eliminar Libreta grande'));
    await tapAndSettle(tester, find.text('Eliminar'));
    expect(controller.products.length, 4);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Perfil actualiza saludo y vuelve al menú', (tester) async {
    viewport(tester, const Size(1440, 1050));
    await tester.runAsync(() async {
      await registerUser(controller);
      await controller.login('ana@example.com', 'Prueba123!');
    });
    await mount(tester, controller, location: '/profile');
    await tester.enterText(
      find.byKey(const Key('profile-name')),
      'María Torres',
    );
    await tester.enterText(
      find.byKey(const Key('profile-phone')),
      '+51 900100200',
    );
    await tapAndSettle(tester, find.byKey(const Key('profile-save')));
    expect(controller.user!.name, 'María Torres');
    await tapAndSettle(tester, find.text('Volver al menú'));
    expect(find.text('Hola, María 👋'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Rutas protegidas y Atrás no abren sesión después de salir', (
    tester,
  ) async {
    viewport(tester, const Size(1440, 1000));
    await mount(tester, controller, location: '/products/new');
    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
    await tester.runAsync(() async {
      await registerUser(controller);
      await controller.login('ana@example.com', 'Prueba123!');
    });
    await tester.pumpAndSettle();
    final router =
        Router.of(tester.element(find.text('Hola, Ana 👋'))).routerDelegate
            as InventiRouter;
    router.go('/profile');
    await tester.pumpAndSettle();
    await tapAndSettle(tester, find.text('Cerrar sesión').first);
    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Hola, Ana 👋'), findsNothing);
    await router.setNewRoutePath('/profile');
    await tester.pumpAndSettle();
    expect(router.currentConfiguration, '/login');
    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
  });

  testWidgets('Navegación móvil sin desbordes en las pantallas internas', (
    tester,
  ) async {
    viewport(tester, const Size(390, 844));
    await tester.runAsync(() async {
      await registerUser(controller);
      await controller.login('ana@example.com', 'Prueba123!');
    });
    await mount(tester, controller);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(tester.takeException(), isNull);
    for (final destination in [
      'Productos',
      'Registrar',
      'Mi perfil',
      'Inicio',
    ]) {
      await tapAndSettle(
        tester,
        find.widgetWithText(NavigationDestination, destination),
      );
      expect(tester.takeException(), isNull, reason: destination);
    }
  });

  testWidgets('Login y registro caben en móvil estrecho', (tester) async {
    viewport(tester, const Size(320, 640));
    await mount(tester, controller, location: '/login');
    expect(tester.takeException(), isNull);
    await tapAndSettle(tester, find.text('Regístrate'));
    expect(tester.takeException(), isNull);
    await tapAndSettle(tester, find.text('Inicia sesión'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Editar un ID ajeno muestra salida funcional', (tester) async {
    viewport(tester, const Size(1440, 1000));
    await tester.runAsync(() async {
      await registerUser(controller);
      await controller.login('ana@example.com', 'Prueba123!');
    });
    await mount(tester, controller, location: '/products/ajeno/edit');
    expect(find.text('Producto no disponible'), findsOneWidget);
    await tapAndSettle(tester, find.text('Volver a productos'));
    expect(find.byKey(const Key('product-search')), findsOneWidget);
  });

  testWidgets('Diseño interno responde en 320, 768 y 960 píxeles', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await registerUser(controller);
      await controller.login('ana@example.com', 'Prueba123!');
    });
    viewport(tester, const Size(320, 740));
    await mount(tester, controller);
    final router =
        Router.of(tester.element(find.text('Hola, Ana 👋'))).routerDelegate
            as InventiRouter;
    for (final width in [320.0, 768.0, 960.0]) {
      tester.view.physicalSize = Size(width, 740);
      for (final route in [
        '/dashboard',
        '/products',
        '/products/new',
        '/profile',
      ]) {
        router.go(route);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$width $route');
      }
    }
  });
}
