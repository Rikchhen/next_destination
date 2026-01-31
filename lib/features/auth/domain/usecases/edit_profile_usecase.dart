import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/core/usecases/app_usecase.dart';
import 'package:next_destination/features/auth/data/repositories/user_repository.dart';
import 'package:next_destination/features/auth/domain/repositories/user_repositroy.dart';

class EditProfileUsecaseParams extends Equatable {
  final String? fullName;
  final String? username;
  final String? email;
  final String? phoneNumber;
  final String? profilePicture;
  const EditProfileUsecaseParams({
    this.fullName,
    this.email,
    this.phoneNumber,
    this.profilePicture,
    this.username,
  });

  @override
  List<Object?> get props => [
    fullName,
    username,
    email,
    phoneNumber,
    profilePicture,
  ];
}

// provider
final editProfileUsecaseProvider = Provider<EditProfileUsecase>((ref) {
  return EditProfileUsecase(userRepository: ref.read(userRepositoryProvider));
});

class EditProfileUsecase
    implements UsecaseWithParams<bool, EditProfileUsecaseParams> {
  final IUserRepository _userRepository;
  EditProfileUsecase({required IUserRepository userRepository})
    : _userRepository = userRepository;
  @override
  Future<Either<Failure, bool>> call(EditProfileUsecaseParams params) {
    final user = EditProfileUsecaseParams(
      fullName: params.fullName,
      username: params.username,
      email: params.email,
      phoneNumber: params.phoneNumber,
      profilePicture: params.profilePicture,
    );

    return _userRepository.editProfile(user);
  }
}
