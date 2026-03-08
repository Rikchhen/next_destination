import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/core/usecases/app_usecase.dart';
import 'package:next_destination/features/business/data/repository/business_repository.dart';
import 'package:next_destination/features/business/domain/repository/business_repository.dart';

class ApproveBusinessUsecaseParams extends Equatable {
  final String businessId;
  final String action;
  final String? reason;

  const ApproveBusinessUsecaseParams({
    required this.businessId,
    required this.action,
    this.reason,
  });

  @override
  List<Object?> get props => [businessId, action, reason];
}

final approveBusinessUsecaseProvider = Provider<ApproveBusinessUsecase>((ref) {
  return ApproveBusinessUsecase(
    businessRepository: ref.read(businessRepositoryProvider),
  );
});

class ApproveBusinessUsecase
    implements UsecaseWithParams<bool, ApproveBusinessUsecaseParams> {
  final IBusinessRepository _businessRepository;

  ApproveBusinessUsecase({required IBusinessRepository businessRepository})
    : _businessRepository = businessRepository;

  @override
  Future<Either<Failure, bool>> call(ApproveBusinessUsecaseParams params) {
    return _businessRepository.approveBusiness(params);
  }
}
