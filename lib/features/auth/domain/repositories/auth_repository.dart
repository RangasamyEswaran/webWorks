import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, User>> getCurrentUser();

  Future<Either<Failure, User>> signup({
    required String email,
    required String password,
    required String name,
  });

  Future<Either<Failure, bool>> checkAuthStatus();
  Future<Either<Failure, void>> saveFcmToken(String token);
}
