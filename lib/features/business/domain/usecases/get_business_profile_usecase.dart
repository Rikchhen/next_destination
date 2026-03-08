import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/core/usecases/app_usecase.dart';
import 'package:next_destination/features/business/data/repository/business_repository.dart';
import 'package:next_destination/features/business/domain/entity/business_entity.dart';
import 'package:next_destination/features/business/domain/repository/business_repository.dart';

final getBusinessProfileUsecaseProvider = Provider<GetBusinessProfileUsecase>((
  ref,
) {
  return GetBusinessProfileUsecase(
    businessRepository: ref.read(businessRepositoryProvider),
  );
});

class GetBusinessProfileUsecase
    implements UsecaseWithoutParams<BusinessEntity> {
  final IBusinessRepository _businessRepository;

  GetBusinessProfileUsecase({required IBusinessRepository businessRepository})
    : _businessRepository = businessRepository;

  @override
  Future<Either<Failure, BusinessEntity>> call() {
    return _businessRepository.getBusinessProfile();
  }
}
