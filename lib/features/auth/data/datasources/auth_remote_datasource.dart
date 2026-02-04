import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/login_request_dto.dart';
import '../models/login_response_dto.dart';
import '../models/user_dto.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseDto> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<LoginResponseDto> signup({
    required String email,
    required String password,
    required String name,
  });

  Future<UserDto> getCurrentUser();
  Future<void> saveFcmToken(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<LoginResponseDto> login({
    required String email,
    required String password,
  }) async {
    try {
      final request = LoginRequestDto(email: email, password: password);
      final response = await apiClient.post(
        ApiConfig.login,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return LoginResponseDto.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Login failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Login failed',
          statusCode: e.response?.statusCode,
        );
      } else {
        throw NetworkException(message: 'No internet connection');
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<LoginResponseDto> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final request = {'email': email, 'password': password, 'name': name};

      final response = await apiClient.post('/auth/register', data: request);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return LoginResponseDto.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Signup failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Signup failed',
          statusCode: e.response?.statusCode,
        );
      } else {
        throw NetworkException(message: 'No internet connection');
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await apiClient.post(ApiConfig.logout);
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Logout failed',
          statusCode: e.response?.statusCode,
        );
      } else {
        throw NetworkException(message: 'No internet connection');
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserDto> getCurrentUser() async {
    try {
      final response = await apiClient.get(ApiConfig.me);

      if (response.statusCode == 200) {
        return UserDto.fromJson(response.data['user'] ?? response.data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to get user',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Failed to get user',
          statusCode: e.response?.statusCode,
        );
      } else {
        throw NetworkException(message: 'No internet connection');
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> saveFcmToken(String token) async {}
}
