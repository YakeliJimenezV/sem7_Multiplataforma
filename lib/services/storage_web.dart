import 'package:web/web.dart' as web;

Future<String?> readSnapshot(String key) async =>
    web.window.localStorage.getItem(key);
Future<void> writeSnapshot(String key, String value) async {
  web.window.localStorage.setItem(key, value);
}
