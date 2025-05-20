import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for the secure storage service
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // Write data securely
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }
  
  // Read data securely
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }
  
  // Delete data securely
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }
  
  // Clear all data from secure storage
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}