import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/core/usecases/app_usecase.dart';
import 'package:next_destination/features/business/data/repository/business_repository.dart';
import 'package:next_destination/features/business/domain/entity/business_entity.dart';
import 'package:next_destination/features/business/domain/repository/business_repository.dart';

class LoginBusinessUsecaseParams extends Equatable {
  final String email;
  final String password;

  const LoginBusinessUsecaseParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

final loginBusinessUsecaseProvider = Provider<LoginBusinessUsecase>((ref) {
  return LoginBusinessUsecase(
    businessRepository: ref.read(businessRepositoryProvider),
  );
});

class LoginBusinessUsecase
    implements UsecaseWithParams<BusinessEntity, LoginBusinessUsecaseParams> {
  final IBusinessRepository _businessRepository;

  LoginBusinessUsecase({required IBusinessRepository businessRepository})
    : _businessRepository = businessRepository;

  @override
  Future<Either<Failure, BusinessEntity>> call(
    LoginBusinessUsecaseParams params,
  ) {
    return _businessRepository.loginBusiness(params.email, params.password);
  }
}
