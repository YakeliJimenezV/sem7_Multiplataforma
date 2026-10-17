import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventi/providers/inventory_controller.dart';
import 'package:inventi/services/local_store.dart';
import 'package:inventi/services/password_service.dart';
import 'helpers.dart';

void main() {
  test(
    'Chrome: localStorage real restaura sesión, perfil e inventario',
    () async {
      final store = PreferencesStore();
      final controller = InventoryController(
        store: store,
        passwords: PasswordService(iterations: 1000),
      );
      await controller.initialize();
      final email =
          'browser${DateTime.now().microsecondsSinceEpoch}@example.com';
      await registerUser(controller, email: email);
      await controller.login(email, 'Prueba123!');
      await controller.updateProfile('Usuario Chrome', '+51 999888777');
      await saveExample(controller);
      final restored = InventoryController(store: PreferencesStore());
      await restored.initialize();
      expect(restored.authenticated, isTrue);
      expect(restored.user!.email, email);
      expect(restored.user!.name, 'Usuario Chrome');
      expect(restored.products.length, 5);
      await restored.logout();
      final signedOut = InventoryController(store: PreferencesStore());
      await signedOut.initialize();
      expect(signedOut.authenticated, isFalse);
      controller.dispose();
      restored.dispose();
      signedOut.dispose();
    },
    skip: !kIsWeb,
  );
}
