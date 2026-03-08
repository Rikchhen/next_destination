import 'package:dartz/dartz.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/features/auth/domain/entities/user_entity.dart';
import 'package:next_destination/features/auth/domain/usecases/edit_profile_usecase.dart';

abstract interface class IUserRepository {
  Future<Either<Failure, bool>> registerUser(UserEntity entity);
  Future<Either<Failure, UserEntity>> loginUser(String email, String password);
  Future<Either<Failure, bool>> logout({bool preserveToken = false});

  // Profile
  Future<Either<Failure, UserEntity>> getProfile();
  Future<Either<Failure, bool>> editProfile(EditProfileUsecaseParams params);
}
