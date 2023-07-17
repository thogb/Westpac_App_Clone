import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageController {
  final FlutterSecureStorage _flutterSecureStorage;

  static final SecureStorageController _secureStorageController =
      SecureStorageController._();

  SecureStorageController._()
      : _flutterSecureStorage = const FlutterSecureStorage();

  static SecureStorageController get instance => _secureStorageController;

  Future<void> write(String key, String value) async {
    await _flutterSecureStorage.write(
        key: key, value: value, aOptions: _getAndroidOptions());
  }

  Future<void> delete(String key) async {
    return _flutterSecureStorage.delete(
        key: key, aOptions: _getAndroidOptions());
  }

  Future<String?> read(String key) async {
    return _flutterSecureStorage.read(key: key, aOptions: _getAndroidOptions());
  }

  Future<bool> containsKey(String key) async {
    return _flutterSecureStorage.containsKey(
        key: key, aOptions: _getAndroidOptions());
  }

  AndroidOptions _getAndroidOptions() {
    return const AndroidOptions(
      encryptedSharedPreferences: true,
    );
  }
}
