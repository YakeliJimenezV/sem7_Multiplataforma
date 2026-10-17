import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../models/product.dart';
import '../services/image_service.dart';
import '../services/local_store.dart';
import '../services/password_service.dart';
import '../services/validators.dart';

class InventoryController extends ChangeNotifier {
  InventoryController({required LocalStore store, PasswordService? passwords})
    : _store = store,
      _passwords = passwords ?? PasswordService();
  final LocalStore _store;
  final PasswordService _passwords;
  List<AppUser> _users = [];
  List<Product> _products = [];
  String? _sessionId;
  bool ready = false;
  bool busy = false;
  String? initializationError;

  AppUser? get user {
    for (final user in _users) {
      if (user.id == _sessionId) return user;
    }
    return null;
  }

  bool get authenticated => user != null;
  List<Product> get products => List.unmodifiable(
    _products.where((product) => product.ownerId == user?.id),
  );
  int get totalUnits =>
      products.fold(0, (total, product) => total + product.stock);
  int get totalValueCents =>
      products.fold(0, (total, p) => total + p.priceCents * p.stock);
  Product? productById(String id) {
    for (final product in products) {
      if (product.id == id) return product;
    }
    return null;
  }

  Future<void> initialize() async {
    ready = false;
    initializationError = null;
    notifyListeners();
    try {
      final raw = await _store.read();
      if (raw != null) {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        if (json['version'] != 1) throw const FormatException('Unknown schema');
        final users = (json['users'] as List)
            .map((e) => AppUser.fromJson(e as Map<String, dynamic>))
            .toList();
        final products = (json['products'] as List)
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList();
        final session = json['sessionId'] as String?;
        _checkSnapshot(users, products);
        _users = users;
        _products = products;
        _sessionId = users.any((u) => u.id == session) ? session : null;
      } else {
        _users = [];
        _products = [];
        _sessionId = null;
      }
      ready = true;
    } catch (_) {
      initializationError =
          'No pudimos abrir los datos locales. Comprueba que el almacenamiento de Chrome esté disponible e inténtalo de nuevo. No se han sobrescrito tus datos.';
    }
    notifyListeners();
  }

  void _checkSnapshot(List<AppUser> users, List<Product> products) {
    final userIds = <String>{};
    final emails = <String>{};
    final productIds = <String>{};
    for (final account in users) {
      if (account.id.isEmpty ||
          !userIds.add(account.id) ||
          !emails.add(account.email.toLowerCase()) ||
          Validators.requiredText(account.name) != null ||
          Validators.email(account.email) != null ||
          Validators.phone(account.phone) != null ||
          base64Decode(account.salt).length != 16 ||
          base64Decode(account.passwordHash).length != 32 ||
          account.iterations < 1 ||
          account.iterations > 2000000) {
        throw const FormatException('Invalid account data');
      }
    }
    for (final product in products) {
      if (product.id.isEmpty ||
          !productIds.add(product.id) ||
          !userIds.contains(product.ownerId) ||
          Validators.requiredText(product.name) != null ||
          Validators.requiredText(product.description, max: 500) != null ||
          product.priceCents < 0 ||
          product.priceCents > 999999999 ||
          product.stock < 0 ||
          product.stock > 9999999 ||
          !productCategories.contains(product.category)) {
        throw const FormatException('Invalid product data');
      }
    }
  }

  Future<void> _operation(Future<void> Function() action) async {
    if (!ready) {
      throw const AppException('El almacenamiento todavía no está disponible.');
    }
    if (busy) {
      throw const AppException('Espera a que termine la operación actual.');
    }
    busy = true;
    notifyListeners();
    try {
      await action();
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException(
        'No se pudo guardar el cambio. Comprueba el espacio y los permisos de almacenamiento e inténtalo de nuevo.',
      );
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  // La memoria cambia únicamente cuando termina la escritura del snapshot.
  Future<void> _commit(
    List<AppUser> users,
    List<Product> products,
    String? session,
  ) async {
    final raw = jsonEncode({
      'version': 1,
      'users': users.map((u) => u.toJson()).toList(),
      'products': products.map((p) => p.toJson()).toList(),
      'sessionId': session,
    });
    // Margen conservador para localStorage UTF-16 y su cuota por origen.
    if (raw.length > 1800000) {
      throw const AppException(
        'El almacenamiento local está lleno. Quita algunas imágenes o usa imágenes más pequeñas.',
      );
    }
    await _store.write(raw);
    _users = users;
    _products = products;
    _sessionId = session;
  }

  void _validate(String? error) {
    if (error != null) throw AppException(error);
  }

  String _requireUser() {
    if (!authenticated) {
      throw const AppException('Inicia sesión para continuar.');
    }
    return user!.id;
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmation,
  }) => _operation(() async {
    _validate(Validators.requiredText(name));
    _validate(Validators.email(email));
    _validate(Validators.phone(phone));
    _validate(Validators.password(password));
    _validate(Validators.confirmPassword(confirmation, password));
    final normalizedEmail = email.trim().toLowerCase();
    if (_users.any((u) => u.email == normalizedEmail)) {
      throw const AppException(
        'Ya existe una cuenta con este correo electrónico.',
      );
    }
    final salt = _passwords.newSalt();
    final account = AppUser(
      id: _passwords.newId(),
      name: name.trim(),
      email: normalizedEmail,
      phone: phone.trim(),
      salt: salt,
      iterations: _passwords.iterations,
      passwordHash: await _passwords.hash(password, salt),
    );
    final examples =
        [
              (
                'Laptop',
                'Potencia y portabilidad para tu día a día.',
                350000,
                10,
              ),
              (
                'Mouse',
                'Mouse ergonómico para trabajar con comodidad.',
                5000,
                25,
              ),
              (
                'Teclado',
                'Teclado de escritorio, práctico y resistente.',
                12000,
                15,
              ),
              (
                'Monitor',
                'Una pantalla amplia para tus mejores ideas.',
                80000,
                8,
              ),
            ]
            .map(
              (e) => Product(
                id: _passwords.newId(),
                ownerId: account.id,
                name: e.$1,
                description: e.$2,
                priceCents: e.$3,
                stock: e.$4,
                category: 'Tecnología',
              ),
            )
            .toList();
    await _commit([..._users, account], [..._products, ...examples], null);
  });
  Future<void> login(String email, String password) => _operation(() async {
    _validate(Validators.email(email));
    _validate(Validators.password(password));
    final matches = _users.where((u) => u.email == email.trim().toLowerCase());
    if (matches.isEmpty ||
        !await _passwords.verify(
          password,
          matches.first.salt,
          matches.first.passwordHash,
          matches.first.iterations,
        )) {
      throw const AppException('Correo o contraseña incorrectos.');
    }
    await _commit(_users, _products, matches.first.id);
  });
  Future<void> logout() => _operation(() async {
    await _commit(_users, _products, null);
  });
  Future<void> updateProfile(String name, String phone) => _operation(() async {
    final id = _requireUser();
    _validate(Validators.requiredText(name));
    _validate(Validators.phone(phone));
    await _commit(
      _users
          .map((u) => u.id == id ? u.withProfile(name.trim(), phone.trim()) : u)
          .toList(),
      _products,
      _sessionId,
    );
  });
  Future<void> saveProduct({
    String? id,
    required String name,
    required String description,
    required String price,
    required String stock,
    required String category,
    String? imageBase64,
  }) => _operation(() async {
    final owner = _requireUser();
    _validate(Validators.requiredText(name));
    _validate(Validators.requiredText(description, max: 500));
    _validate(Validators.price(price));
    _validate(Validators.stock(stock));
    if (!productCategories.contains(category)) {
      throw const AppException('Selecciona una categoría válida.');
    }
    if (id != null && productById(id) == null) {
      throw const AppException('Este producto no está disponible.');
    }
    if (imageBase64 != null) {
      await ImageService.validateAndEncode(base64Decode(imageBase64));
    }
    final product = Product(
      id: id ?? _passwords.newId(),
      ownerId: owner,
      name: name.trim(),
      description: description.trim(),
      priceCents: Validators.priceToCents(price),
      stock: int.parse(stock.trim()),
      category: category,
      imageBase64: imageBase64,
    );
    final updated = id == null
        ? [..._products, product]
        : _products
              .map((p) => p.id == id && p.ownerId == owner ? product : p)
              .toList();
    await _commit(_users, updated, _sessionId);
  });
  Future<void> deleteProduct(String id) => _operation(() async {
    final owner = _requireUser();
    if (productById(id) == null) {
      throw const AppException('Este producto no está disponible.');
    }
    await _commit(
      _users,
      _products.where((p) => !(p.id == id && p.ownerId == owner)).toList(),
      _sessionId,
    );
  });
}
