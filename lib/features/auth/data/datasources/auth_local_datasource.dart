import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_dto.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheAuthToken(String token);
  Future<void> cacheRefreshToken(String? token);
  Future<void> cacheUser(UserDto user);
  Future<String?> getAuthToken();
  Future<UserDto?> getCachedUser();
  Future<bool> isLoggedIn();
  Future<void> clearAuthData();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl(this.secureStorage);

  @override
  Future<void> cacheAuthToken(String token) async {
    try {
      await secureStorage.write(key: StorageKeys.authToken, value: token);
      await secureStorage.write(key: StorageKeys.isLoggedIn, value: 'true');
    } catch (e) {
      throw CacheException(message: 'Failed to cache auth token');
    }
  }

  @override
  Future<void> cacheRefreshToken(String? token) async {
    try {
      if (token != null) {
        await secureStorage.write(key: StorageKeys.refreshToken, value: token);
      }
    } catch (e) {
      throw CacheException(message: 'Failed to cache refresh token');
    }
  }

  @override
  Future<void> cacheUser(UserDto user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await secureStorage.write(key: StorageKeys.userData, value: userJson);
      await secureStorage.write(key: StorageKeys.userId, value: user.id);
      await secureStorage.write(key: StorageKeys.userEmail, value: user.email);
    } catch (e) {
      throw CacheException(message: 'Failed to cache user data');
    }
  }

  @override
  Future<String?> getAuthToken() async {
    try {
      return await secureStorage.read(key: StorageKeys.authToken);
    } catch (e) {
      throw CacheException(message: 'Failed to get auth token');
    }
  }

  @override
  Future<UserDto?> getCachedUser() async {
    try {
      final userJson = await secureStorage.read(key: StorageKeys.userData);
      if (userJson != null) {
        return UserDto.fromJson(jsonDecode(userJson));
      }
      return null;
    } catch (e) {
      throw CacheException(message: 'Failed to get cached user');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final isLoggedIn = await secureStorage.read(key: StorageKeys.isLoggedIn);
      final token = await secureStorage.read(key: StorageKeys.authToken);
      return isLoggedIn == 'true' && token != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> clearAuthData() async {
    try {
      await secureStorage.delete(key: StorageKeys.authToken);
      await secureStorage.delete(key: StorageKeys.refreshToken);
      await secureStorage.delete(key: StorageKeys.userData);
      await secureStorage.delete(key: StorageKeys.userId);
      await secureStorage.delete(key: StorageKeys.userEmail);
      await secureStorage.write(key: StorageKeys.isLoggedIn, value: 'false');
    } catch (e) {
      throw CacheException(message: 'Failed to clear auth data');
    }
  }
}
