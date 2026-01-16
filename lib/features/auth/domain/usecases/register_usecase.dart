import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/core/usecases/app_usecase.dart';
import 'package:next_destination/features/auth/data/repositories/user_repository.dart';
import 'package:next_destination/features/auth/domain/entities/user_entity.dart';
import 'package:next_destination/features/auth/domain/repositories/user_repositroy.dart';

class RegisterUsecaseParams extends Equatable {
  final String fullName;
  final String email;
  final String password;
  final String phoneNumber;
  final String confirmPassword;
  const RegisterUsecaseParams({
    required this.fullName,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [fullName, email, password, phoneNumber];
}

// Provider for register usecase.
final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  return RegisterUsecase(userRepository: ref.read(userRepositoryProvider));
});

class RegisterUsecase
    implements UsecaseWithParams<bool, RegisterUsecaseParams> {
  final IUserRepository _userRepository;
  RegisterUsecase({required IUserRepository userRepository})
    : _userRepository = userRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterUsecaseParams params) {
    final userEntity = UserEntity(
      fullName: params.fullName,
      email: params.email,
      password: params.password,
      confirmPassword: params.confirmPassword,
      phoneNumber: params.phoneNumber,
    );
    return _userRepository.registerUser(userEntity);
  }
}
