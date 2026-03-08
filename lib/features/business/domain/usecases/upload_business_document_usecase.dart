import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/core/usecases/app_usecase.dart';
import 'package:next_destination/features/business/data/repository/business_repository.dart';
import 'package:next_destination/features/business/domain/repository/business_repository.dart';

class UploadBusinessDocumentUsecaseParams extends Equatable {
  final String documentPath;

  const UploadBusinessDocumentUsecaseParams({required this.documentPath});

  @override
  List<Object?> get props => [documentPath];
}

final uploadBusinessDocumentUsecaseProvider =
    Provider<UploadBusinessDocumentUsecase>((ref) {
      return UploadBusinessDocumentUsecase(
        businessRepository: ref.read(businessRepositoryProvider),
      );
    });

class UploadBusinessDocumentUsecase
    implements UsecaseWithParams<bool, UploadBusinessDocumentUsecaseParams> {
  final IBusinessRepository _businessRepository;

  UploadBusinessDocumentUsecase({
    required IBusinessRepository businessRepository,
  }) : _businessRepository = businessRepository;

  @override
  Future<Either<Failure, bool>> call(
    UploadBusinessDocumentUsecaseParams params,
  ) {
    return _businessRepository.uploadBusinessDocument(params.documentPath);
  }
}
