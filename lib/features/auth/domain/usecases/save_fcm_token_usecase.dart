import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/auth_repository.dart';

class SaveFcmTokenUseCase {
  final AuthRepository repository;

  SaveFcmTokenUseCase(this.repository);

  Future<Either<Failure, void>> call(String token) async {
    return await repository.saveFcmToken(token);
  }
}
