import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/core/usecases/app_usecase.dart';
import 'package:next_destination/features/payment/data/repository/payment_repository.dart';
import 'package:next_destination/features/payment/domain/entity/payment_initiation_entity.dart';
import 'package:next_destination/features/payment/domain/repository/payment_repository.dart';

class InitiateKhaltiPaymentParams extends Equatable {
  final String bookingId;
  final String returnUrl;

  const InitiateKhaltiPaymentParams({
    required this.bookingId,
    required this.returnUrl,
  });

  @override
  List<Object?> get props => [bookingId, returnUrl];
}

final initiateKhaltiPaymentUsecaseProvider = Provider<InitiateKhaltiPaymentUsecase>((
  ref,
) {
  return InitiateKhaltiPaymentUsecase(
    repository: ref.read(paymentRepositoryProvider),
  );
});

class InitiateKhaltiPaymentUsecase
    implements
        UsecaseWithParams<PaymentInitiationEntity, InitiateKhaltiPaymentParams> {
  final IPaymentRepository _repository;

  InitiateKhaltiPaymentUsecase({required IPaymentRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, PaymentInitiationEntity>> call(
    InitiateKhaltiPaymentParams params,
  ) {
    return _repository.initiateKhaltiPayment(
      bookingId: params.bookingId,
      returnUrl: params.returnUrl,
    );
  }
}

