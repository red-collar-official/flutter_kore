// coverage:ignore-file

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final _storage = const FlutterSecureStorage();

  late Map<String, String> entries;

  Future<void> initialize() async {
    entries = await _storage.readAll();
  }

  String? getString(String key) {
    return entries[key];
  }

  Future<bool> putString(String key, String value) async {
    entries[key] = value;

    await _storage.write(key: key, value: value);

    return true;
  }

  Future<bool> deleteAll(bool Function(String) predicate) async {
    final keysToRemove = <String>[];

    for (final key in entries.keys) {
      if (predicate(key)) {
        keysToRemove.add(key);
      }
    }

    for (final key in keysToRemove) {
      entries.remove(key);

      await _storage.delete(key: key);
    }

    return true;
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }
}
