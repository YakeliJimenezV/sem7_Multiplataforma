import 'storage_native.dart'
    if (dart.library.js_interop) 'storage_web.dart'
    as platform;

abstract interface class LocalStore {
  Future<String?> read();
  Future<void> write(String value);
}

class PreferencesStore implements LocalStore {
  static const storageKey = 'inventi.snapshot.v1';
  @override
  Future<String?> read() => platform.readSnapshot(storageKey);
  @override
  Future<void> write(String value) => platform.writeSnapshot(storageKey, value);
}

class AppException implements Exception {
  const AppException(this.message);
  final String message;
  @override
  String toString() => message;
}
