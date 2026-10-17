import 'dart:io';

Future<File> _file(String key) async {
  final localData = Platform.environment['LOCALAPPDATA'];
  final userDirectory = Platform.environment['HOME'];
  final String directoryPath;
  if (Platform.isWindows && localData != null) {
    directoryPath = '$localData${Platform.pathSeparator}Inventi';
  } else if (Platform.isMacOS && userDirectory != null) {
    directoryPath = '$userDirectory/Library/Application Support/Inventi';
  } else if (Platform.isLinux && userDirectory != null) {
    directoryPath =
        '${Platform.environment['XDG_DATA_HOME'] ?? '$userDirectory/.local/share'}/inventi';
  } else {
    throw UnsupportedError(
      'La persistencia de Inventi está disponible en Chrome y escritorio.',
    );
  }
  final directory = Directory(directoryPath);
  await directory.create(recursive: true);
  return File('${directory.path}${Platform.pathSeparator}$key.json');
}

Future<String?> readSnapshot(String key) async {
  final file = await _file(key);
  return await file.exists() ? file.readAsString() : null;
}

Future<void> writeSnapshot(String key, String value) async {
  final file = await _file(key);
  final temporary = File('${file.path}.tmp');
  await temporary.writeAsString(value, flush: true);
  await temporary.rename(file.path);
}
