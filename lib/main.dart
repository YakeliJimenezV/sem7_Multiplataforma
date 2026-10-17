import 'package:flutter/material.dart';
import 'app.dart';
import 'providers/inventory_controller.dart';
import 'services/local_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = InventoryController(store: PreferencesStore());
  runApp(InventiBootstrap(controller: controller));
  controller.initialize();
}
