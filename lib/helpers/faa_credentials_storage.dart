import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FaaCredentialsStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveCredentials(String username, String password) async {
    await _storage.write(key: 'faa_username', value: username);
    await _storage.write(key: 'faa_password', value: password);
  }

  static Future<Map<String, String>?> getCredentials() async {
    final username = await _storage.read(key: 'faa_username');
    final password = await _storage.read(key: 'faa_password');
    if (username != null && password != null) {
      return {'username': username, 'password': password};
    }
    return null;
  }

  static Future<void> deleteCredentials() async {
    await _storage.delete(key: 'faa_username');
    await _storage.delete(key: 'faa_password');
  }
}
