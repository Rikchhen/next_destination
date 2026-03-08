import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/features/payment/domain/entity/payment_entity.dart';
import 'package:next_destination/features/payment/domain/entity/payment_initiation_entity.dart';
import 'package:next_destination/features/payment/domain/usecases/get_payment_by_booking_usecase.dart';
import 'package:next_destination/features/payment/domain/usecases/initiate_khalti_payment_usecase.dart';
import 'package:next_destination/features/payment/domain/usecases/verify_khalti_payment_usecase.dart';
import 'package:next_destination/features/payment/presentation/viewmodel/payment_view_model.dart';

class MockInitiateKhaltiPaymentUsecase extends Mock
    implements InitiateKhaltiPaymentUsecase {}

class MockVerifyKhaltiPaymentUsecase extends Mock
    implements VerifyKhaltiPaymentUsecase {}

class MockGetPaymentByBookingUsecase extends Mock
    implements GetPaymentByBookingUsecase {}

class PaymentFeatureTestScreen extends ConsumerWidget {
  const PaymentFeatureTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paymentViewModelProvider);
    final vm = ref.read(paymentViewModelProvider.notifier);

    return Scaffold(
      body: Column(
        children: [
          Text('status:${state.status.name}', key: const Key('status')),
          Text('error:${state.errorMessage ?? ''}', key: const Key('error')),
          ElevatedButton(
            key: const Key('initiate'),
            onPressed: () =>
                vm.initiatePayment(bookingId: 'b1', returnUrl: 'app://return'),
            child: const Text('initiate'),
          ),
          ElevatedButton(
            key: const Key('verify'),
            onPressed: () => vm.verifyPayment(pidx: 'pidx_123', bookingId: 'b1'),
            child: const Text('verify'),
          ),
          ElevatedButton(
            key: const Key('fetch'),
            onPressed: () => vm.getPaymentByBookingId('b1'),
            child: const Text('fetch'),
          ),
        ],
      ),
    );
  }
}

void main() {
  late MockInitiateKhaltiPaymentUsecase mockInitiate;
  late MockVerifyKhaltiPaymentUsecase mockVerify;
  late MockGetPaymentByBookingUsecase mockGetByBooking;

  final payment = PaymentEntity(
    paymentId: 'p1',
    userId: 'u1',
    bookingId: 'b1',
    amount: 2500,
    status: 'pending',
    paymentMethod: 'khalti',
    pidx: 'pidx_123',
    paymentUrl: 'https://pay.khalti.com',
    createdAt: DateTime(2026, 1, 1),
  );

  final initiation = PaymentInitiationEntity(
    payment: PaymentEntity(
      paymentId: 'p1',
      userId: 'u1',
      bookingId: 'b1',
      amount: 2500,
      status: 'pending',
      paymentMethod: 'khalti',
      pidx: 'pidx_123',
      paymentUrl: 'https://pay.khalti.com',
      createdAt: DateTime(2026, 1, 1),
    ),
    paymentUrl: 'https://pay.khalti.com',
    pidx: 'pidx_123',
  );

  Widget makeApp() {
    return ProviderScope(
      overrides: [
        initiateKhaltiPaymentUsecaseProvider.overrideWithValue(mockInitiate),
        verifyKhaltiPaymentUsecaseProvider.overrideWithValue(mockVerify),
        getPaymentByBookingUsecaseProvider.overrideWithValue(mockGetByBooking),
      ],
      child: const MaterialApp(home: PaymentFeatureTestScreen()),
    );
  }

  setUp(() {
    mockInitiate = MockInitiateKhaltiPaymentUsecase();
    mockVerify = MockVerifyKhaltiPaymentUsecase();
    mockGetByBooking = MockGetPaymentByBookingUsecase();
  });

  testWidgets('payment widget shows initial status', (tester) async {
    await tester.pumpWidget(makeApp());
    expect(find.text('status:initial'), findsOneWidget);
  });

  testWidgets('initiate button shows initiated on success', (tester) async {
    const params = InitiateKhaltiPaymentParams(
      bookingId: 'b1',
      returnUrl: 'app://return',
    );
    when(() => mockInitiate(params)).thenAnswer((_) async => Right(initiation));

    await tester.pumpWidget(makeApp());
    await tester.tap(find.byKey(const Key('initiate')));
    await tester.pumpAndSettle();

    expect(find.text('status:initiated'), findsOneWidget);
  });

  testWidgets('initiate button shows error on failure', (tester) async {
    const params = InitiateKhaltiPaymentParams(
      bookingId: 'b1',
      returnUrl: 'app://return',
    );
    const failure = ApiFailure(message: 'Khalti unavailable', statusCode: 503);
    when(() => mockInitiate(params)).thenAnswer((_) async => const Left(failure));

    await tester.pumpWidget(makeApp());
    await tester.tap(find.byKey(const Key('initiate')));
    await tester.pumpAndSettle();

    expect(find.text('status:error'), findsOneWidget);
    expect(find.text('error:Khalti unavailable'), findsOneWidget);
  });

  testWidgets('verify button shows verified on success', (tester) async {
    const params = VerifyKhaltiPaymentParams(pidx: 'pidx_123', bookingId: 'b1');
    when(() => mockVerify(params)).thenAnswer((_) async => Right(payment));

    await tester.pumpWidget(makeApp());
    await tester.tap(find.byKey(const Key('verify')));
    await tester.pumpAndSettle();

    expect(find.text('status:verified'), findsOneWidget);
  });

  testWidgets('fetch button shows fetched on success', (tester) async {
    when(() => mockGetByBooking('b1')).thenAnswer((_) async => Right(payment));

    await tester.pumpWidget(makeApp());
    await tester.tap(find.byKey(const Key('fetch')));
    await tester.pumpAndSettle();

    expect(find.text('status:fetched'), findsOneWidget);
  });
}
