import 'package:dartz/dartz.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/features/payment/domain/entity/payment_entity.dart';
import 'package:next_destination/features/payment/domain/entity/payment_initiation_entity.dart';

abstract interface class IPaymentRepository {
  Future<Either<Failure, PaymentInitiationEntity>> initiateKhaltiPayment({
    required String bookingId,
    required String returnUrl,
  });

  Future<Either<Failure, PaymentEntity>> verifyKhaltiPayment({
    required String pidx,
    required String bookingId,
  });

  Future<Either<Failure, PaymentEntity?>> getPaymentByBookingId(String bookingId);
}

