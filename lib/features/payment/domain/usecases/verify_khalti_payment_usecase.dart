import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/core/usecases/app_usecase.dart';
import 'package:next_destination/features/payment/data/repository/payment_repository.dart';
import 'package:next_destination/features/payment/domain/entity/payment_entity.dart';
import 'package:next_destination/features/payment/domain/repository/payment_repository.dart';

class VerifyKhaltiPaymentParams extends Equatable {
  final String pidx;
  final String bookingId;

  const VerifyKhaltiPaymentParams({
    required this.pidx,
    required this.bookingId,
  });

  @override
  List<Object?> get props => [pidx, bookingId];
}

final verifyKhaltiPaymentUsecaseProvider = Provider<VerifyKhaltiPaymentUsecase>((
  ref,
) {
  return VerifyKhaltiPaymentUsecase(repository: ref.read(paymentRepositoryProvider));
});

class VerifyKhaltiPaymentUsecase
    implements UsecaseWithParams<PaymentEntity, VerifyKhaltiPaymentParams> {
  final IPaymentRepository _repository;

  VerifyKhaltiPaymentUsecase({required IPaymentRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, PaymentEntity>> call(VerifyKhaltiPaymentParams params) {
    return _repository.verifyKhaltiPayment(
      pidx: params.pidx,
      bookingId: params.bookingId,
    );
  }
}

