import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/core/usecases/app_usecase.dart';
import 'package:next_destination/features/payment/data/repository/payment_repository.dart';
import 'package:next_destination/features/payment/domain/entity/payment_entity.dart';
import 'package:next_destination/features/payment/domain/repository/payment_repository.dart';

final getPaymentByBookingUsecaseProvider = Provider<GetPaymentByBookingUsecase>((ref) {
  return GetPaymentByBookingUsecase(repository: ref.read(paymentRepositoryProvider));
});

class GetPaymentByBookingUsecase
    implements UsecaseWithParams<PaymentEntity?, String> {
  final IPaymentRepository _repository;

  GetPaymentByBookingUsecase({required IPaymentRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, PaymentEntity?>> call(String params) {
    return _repository.getPaymentByBookingId(params);
  }
}

