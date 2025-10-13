// coverage:ignore-file

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final _storage = const FlutterSecureStorage();

  AndroidOptions _getAndroidOptions() =>
      const AndroidOptions(encryptedSharedPreferences: true);

  late Map<String, String> entries;

  Future<void> initialize() async {
    entries = await _storage.readAll(
      aOptions: _getAndroidOptions(),
    );
  }

  String? getString(String key) {
    return entries[key];
  }

  Future<bool> putString(String key, String value) async {
    entries['key'] = value;

    await _storage.write(key: key, value: value);

    return true;
  }

  Future<void> clear() async {
    await _storage.deleteAll(aOptions: _getAndroidOptions());
  }
}
