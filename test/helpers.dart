import 'package:inventi/providers/inventory_controller.dart';
import 'package:inventi/services/local_store.dart';
import 'package:inventi/services/password_service.dart';

class MemoryStore implements LocalStore {
  String? value;
  bool failRead = false;
  bool failWrite = false;
  @override
  Future<String?> read() async {
    if (failRead) throw StateError('Storage unavailable');
    return value;
  }

  @override
  Future<void> write(String value) async {
    if (failWrite) throw StateError('Quota exceeded');
    this.value = value;
  }
}

InventoryController makeController(MemoryStore store) => InventoryController(
  store: store,
  passwords: PasswordService(iterations: 1000),
);

Future<void> registerUser(
  InventoryController controller, {
  String email = 'ana@example.com',
  String name = 'Ana Torres',
}) => controller.register(
  name: name,
  email: email,
  phone: '999888777',
  password: 'Prueba123!',
  confirmation: 'Prueba123!',
);

Future<void> saveExample(
  InventoryController controller, {
  String? id,
  String price = '19.90',
  String stock = '4',
  String name = 'Libreta',
  String category = 'Oficina',
  String? image,
}) => controller.saveProduct(
  id: id,
  name: name,
  description: 'Libreta de notas.',
  price: price,
  stock: stock,
  category: category,
  imageBase64: image,
);
