import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/core/usecases/app_usecase.dart';
import 'package:next_destination/features/business/data/repository/business_repository.dart';
import 'package:next_destination/features/business/domain/repository/business_repository.dart';

class RegisterBusinessUsecaseParams extends Equatable {
  final String businessName;
  final String email;
  final String phoneNumber;
  final String password;
  final String? address;
  final String profilePicture;

  const RegisterBusinessUsecaseParams({
    required this.businessName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    this.address,
    required this.profilePicture,
  });

  @override
  List<Object?> get props => [
    businessName,
    email,
    phoneNumber,
    password,
    address,
    profilePicture,
  ];
}

final registerBusinessUsecaseProvider = Provider<RegisterBusinessUsecase>((
  ref,
) {
  return RegisterBusinessUsecase(
    businessRepository: ref.read(businessRepositoryProvider),
  );
});

class RegisterBusinessUsecase
    implements UsecaseWithParams<bool, RegisterBusinessUsecaseParams> {
  final IBusinessRepository _businessRepository;

  RegisterBusinessUsecase({required IBusinessRepository businessRepository})
    : _businessRepository = businessRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterBusinessUsecaseParams params) {
    return _businessRepository.registerBusiness(params);
  }
}
