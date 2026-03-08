import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/features/payment/domain/entity/payment_entity.dart';
import 'package:next_destination/features/payment/domain/entity/payment_initiation_entity.dart';
import 'package:next_destination/features/payment/domain/repository/payment_repository.dart';
import 'package:next_destination/features/payment/domain/usecases/get_payment_by_booking_usecase.dart';
import 'package:next_destination/features/payment/domain/usecases/initiate_khalti_payment_usecase.dart';

class MockPaymentRepository extends Mock implements IPaymentRepository {}

void main() {
  late MockPaymentRepository repository;
  late InitiateKhaltiPaymentUsecase initiateUsecase;
  late GetPaymentByBookingUsecase getPaymentByBookingUsecase;

  final tPayment = PaymentEntity(
    paymentId: 'p1',
    userId: 'u1',
    bookingId: 'b1',
    amount: 2500,
    status: 'pending',
    paymentMethod: 'khalti',
    pidx: 'pidx_123',
    paymentUrl: 'https://pay.khalti.com',
    createdAt: DateTime(2026, 1, 5),
  );

  final tInitiation = PaymentInitiationEntity(
    payment: PaymentEntity(
      paymentId: 'p1',
      userId: 'u1',
      bookingId: 'b1',
      amount: 2500,
      status: 'pending',
      paymentMethod: 'khalti',
      pidx: 'pidx_123',
      paymentUrl: 'https://pay.khalti.com',
      createdAt: DateTime(2026, 1, 5),
    ),
    paymentUrl: 'https://pay.khalti.com',
    pidx: 'pidx_123',
  );

  setUp(() {
    repository = MockPaymentRepository();
    initiateUsecase = InitiateKhaltiPaymentUsecase(repository: repository);
    getPaymentByBookingUsecase = GetPaymentByBookingUsecase(repository: repository);
  });

  group('InitiateKhaltiPaymentUsecase', () {
    test('returns payment initiation data on success', () async {
      const params = InitiateKhaltiPaymentParams(
        bookingId: 'b1',
        returnUrl: 'app://return',
      );
      when(
        () => repository.initiateKhaltiPayment(
          bookingId: params.bookingId,
          returnUrl: params.returnUrl,
        ),
      ).thenAnswer((_) async => Right(tInitiation));

      final result = await initiateUsecase(params);

      expect(result, Right<Failure, PaymentInitiationEntity>(tInitiation));
    });

    test('returns failure when initiation fails', () async {
      const params = InitiateKhaltiPaymentParams(
        bookingId: 'b1',
        returnUrl: 'app://return',
      );
      const failure = ApiFailure(message: 'Khalti unavailable', statusCode: 503);
      when(
        () => repository.initiateKhaltiPayment(
          bookingId: params.bookingId,
          returnUrl: params.returnUrl,
        ),
      ).thenAnswer((_) async => const Left(failure));

      final result = await initiateUsecase(params);

      expect(result, const Left<Failure, PaymentInitiationEntity>(failure));
    });

    test('forwards bookingId and returnUrl exactly once', () async {
      const params = InitiateKhaltiPaymentParams(
        bookingId: 'booking-x',
        returnUrl: 'myapp://khalti-return',
      );
      when(
        () => repository.initiateKhaltiPayment(
          bookingId: params.bookingId,
          returnUrl: params.returnUrl,
        ),
      ).thenAnswer((_) async => Right(tInitiation));

      await initiateUsecase(params);

      verify(
        () => repository.initiateKhaltiPayment(
          bookingId: 'booking-x',
          returnUrl: 'myapp://khalti-return',
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    });
  });

  group('GetPaymentByBookingUsecase', () {
    test('returns payment when booking has payment record', () async {
      when(
        () => repository.getPaymentByBookingId('b1'),
      ).thenAnswer((_) async => Right(tPayment));

      final result = await getPaymentByBookingUsecase('b1');

      expect(result, Right<Failure, PaymentEntity?>(tPayment));
    });

    test('returns failure when fetching payment by booking fails', () async {
      const failure = NetworkFailure(message: 'No internet connection');
      when(
        () => repository.getPaymentByBookingId('b-missing'),
      ).thenAnswer((_) async => const Left(failure));

      final result = await getPaymentByBookingUsecase('b-missing');

      expect(result, const Left<Failure, PaymentEntity?>(failure));
      verify(() => repository.getPaymentByBookingId('b-missing')).called(1);
      verifyNoMoreInteractions(repository);
    });
  });
}
