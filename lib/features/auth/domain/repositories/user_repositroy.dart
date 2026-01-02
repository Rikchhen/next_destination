import 'package:dartz/dartz.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/features/auth/domain/entities/user_entity.dart';

abstract interface class IUserRepository {
  Future<Either<Failure, bool>> registerUser(UserEntity entity);
  Future<Either<Failure, UserEntity>> loginUser(
    String phoneNumber,
    String password,
  );
  Future<Either<Failure, UserEntity>> getCurrentUser();
  Future<Either<Failure, bool>> logout();
}
