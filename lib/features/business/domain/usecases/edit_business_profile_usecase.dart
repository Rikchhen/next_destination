import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/core/usecases/app_usecase.dart';
import 'package:next_destination/features/business/data/repository/business_repository.dart';
import 'package:next_destination/features/business/domain/repository/business_repository.dart';

class EditBusinessProfileUsecaseParams extends Equatable {
  final String? businessName;
  final String? email;
  final String? phoneNumber;
  final String? address;
  final String? profilePicture;

  const EditBusinessProfileUsecaseParams({
    this.businessName,
    this.email,
    this.phoneNumber,
    this.address,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [
    businessName,
    email,
    phoneNumber,
    address,
    profilePicture,
  ];
}

final editBusinessProfileUsecaseProvider = Provider<EditBusinessProfileUsecase>(
  (ref) {
    return EditBusinessProfileUsecase(
      businessRepository: ref.read(businessRepositoryProvider),
    );
  },
);

class EditBusinessProfileUsecase
    implements UsecaseWithParams<bool, EditBusinessProfileUsecaseParams> {
  final IBusinessRepository _businessRepository;

  EditBusinessProfileUsecase({required IBusinessRepository businessRepository})
    : _businessRepository = businessRepository;

  @override
  Future<Either<Failure, bool>> call(EditBusinessProfileUsecaseParams params) {
    return _businessRepository.editBusinessProfile(params);
  }
}
