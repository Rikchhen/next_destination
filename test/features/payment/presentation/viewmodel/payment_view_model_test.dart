import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/features/payment/domain/entity/payment_entity.dart';
import 'package:next_destination/features/payment/domain/entity/payment_initiation_entity.dart';
import 'package:next_destination/features/payment/domain/usecases/get_payment_by_booking_usecase.dart';
import 'package:next_destination/features/payment/domain/usecases/initiate_khalti_payment_usecase.dart';
import 'package:next_destination/features/payment/domain/usecases/verify_khalti_payment_usecase.dart';
import 'package:next_destination/features/payment/presentation/state/payment_state.dart';
import 'package:next_destination/features/payment/presentation/viewmodel/payment_view_model.dart';

class MockInitiateKhaltiPaymentUsecase extends Mock
    implements InitiateKhaltiPaymentUsecase {}

class MockVerifyKhaltiPaymentUsecase extends Mock
    implements VerifyKhaltiPaymentUsecase {}

class MockGetPaymentByBookingUsecase extends Mock
    implements GetPaymentByBookingUsecase {}

void main() {
  late MockInitiateKhaltiPaymentUsecase mockInitiateUsecase;
  late MockVerifyKhaltiPaymentUsecase mockVerifyUsecase;
  late MockGetPaymentByBookingUsecase mockGetByBookingUsecase;
  late ProviderContainer container;

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
    mockInitiateUsecase = MockInitiateKhaltiPaymentUsecase();
    mockVerifyUsecase = MockVerifyKhaltiPaymentUsecase();
    mockGetByBookingUsecase = MockGetPaymentByBookingUsecase();

    container = ProviderContainer(
      overrides: [
        initiateKhaltiPaymentUsecaseProvider.overrideWithValue(mockInitiateUsecase),
        verifyKhaltiPaymentUsecaseProvider.overrideWithValue(mockVerifyUsecase),
        getPaymentByBookingUsecaseProvider.overrideWithValue(mockGetByBookingUsecase),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('initial state is PaymentStatus.initial', () {
    final state = container.read(paymentViewModelProvider);
    expect(state.status, PaymentStatus.initial);
    expect(state.payment, isNull);
  });

  test('initiatePayment success sets initiated state with payment URL and pidx', () async {
    const params = InitiateKhaltiPaymentParams(
      bookingId: 'b1',
      returnUrl: 'app://return',
    );
    when(() => mockInitiateUsecase(params)).thenAnswer((_) async => Right(tInitiation));

    await container
        .read(paymentViewModelProvider.notifier)
        .initiatePayment(bookingId: 'b1', returnUrl: 'app://return');

    final state = container.read(paymentViewModelProvider);
    expect(state.status, PaymentStatus.initiated);
    expect(state.payment, tPayment);
    expect(state.paymentUrl, 'https://pay.khalti.com');
    expect(state.pidx, 'pidx_123');
  });

  test('initiatePayment failure sets error state', () async {
    const params = InitiateKhaltiPaymentParams(
      bookingId: 'b1',
      returnUrl: 'app://return',
    );
    const failure = ApiFailure(message: 'Khalti unavailable', statusCode: 503);
    when(
      () => mockInitiateUsecase(params),
    ).thenAnswer((_) async => const Left(failure));

    await container
        .read(paymentViewModelProvider.notifier)
        .initiatePayment(bookingId: 'b1', returnUrl: 'app://return');

    final state = container.read(paymentViewModelProvider);
    expect(state.status, PaymentStatus.error);
    expect(state.errorMessage, 'Khalti unavailable');
  });

  test('verifyPayment success sets verified state with payment details', () async {
    const params = VerifyKhaltiPaymentParams(pidx: 'pidx_123', bookingId: 'b1');
    when(() => mockVerifyUsecase(params)).thenAnswer((_) async => Right(tPayment));

    await container
        .read(paymentViewModelProvider.notifier)
        .verifyPayment(pidx: 'pidx_123', bookingId: 'b1');

    final state = container.read(paymentViewModelProvider);
    expect(state.status, PaymentStatus.verified);
    expect(state.payment, tPayment);
  });

  test('getPaymentByBookingId failure sets error state', () async {
    const failure = NetworkFailure(message: 'No internet connection');
    when(
      () => mockGetByBookingUsecase('missing-booking'),
    ).thenAnswer((_) async => const Left(failure));

    await container
        .read(paymentViewModelProvider.notifier)
        .getPaymentByBookingId('missing-booking');

    final state = container.read(paymentViewModelProvider);
    expect(state.status, PaymentStatus.error);
    expect(state.errorMessage, 'No internet connection');
  });
}
