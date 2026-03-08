import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/features/ticket/domain/entity/ticket_entity.dart';
import 'package:next_destination/features/ticket/domain/usecases/get_ticket_by_id_usecase.dart';
import 'package:next_destination/features/ticket/domain/usecases/get_tickets_by_booking_usecase.dart';
import 'package:next_destination/features/ticket/domain/usecases/scan_ticket_usecase.dart';
import 'package:next_destination/features/ticket/domain/usecases/void_ticket_usecase.dart';
import 'package:next_destination/features/ticket/presentation/viewmodel/ticket_view_model.dart';

class MockGetTicketByIdUsecase extends Mock implements GetTicketByIdUsecase {}

class MockGetTicketsByBookingUsecase extends Mock
    implements GetTicketsByBookingUsecase {}

class MockScanTicketUsecase extends Mock implements ScanTicketUsecase {}

class MockVoidTicketUsecase extends Mock implements VoidTicketUsecase {}

class TicketFeatureTestScreen extends ConsumerWidget {
  const TicketFeatureTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ticketViewModelProvider);
    final vm = ref.read(ticketViewModelProvider.notifier);

    return Scaffold(
      body: Column(
        children: [
          Text('status:${state.status.name}', key: const Key('status')),
          Text('error:${state.errorMessage ?? ''}', key: const Key('error')),
          ElevatedButton(
            key: const Key('byId'),
            onPressed: () => vm.getTicketById('tk1'),
            child: const Text('byId'),
          ),
          ElevatedButton(
            key: const Key('booking'),
            onPressed: () => vm.getTicketsByBooking('b1'),
            child: const Text('booking'),
          ),
          ElevatedButton(
            key: const Key('scan'),
            onPressed: () => vm.scanTicket('qr_123'),
            child: const Text('scan'),
          ),
        ],
      ),
    );
  }
}

void main() {
  late MockGetTicketByIdUsecase mockGetById;
  late MockGetTicketsByBookingUsecase mockGetByBooking;
  late MockScanTicketUsecase mockScan;
  late MockVoidTicketUsecase mockVoid;

  final ticket = TicketEntity(
    ticketId: 'tk1',
    booking: 'b1',
    trip: 't1',
    bookedBy: 'u1',
    passengerName: 'Ram',
    seatNumber: 'A1',
    qrToken: 'qr_123',
    status: 'issued',
    issuedAt: DateTime(2026, 1, 1),
  );

  Widget makeApp() {
    return ProviderScope(
      overrides: [
        getTicketByIdUsecaseProvider.overrideWithValue(mockGetById),
        getTicketsByBookingUsecaseProvider.overrideWithValue(mockGetByBooking),
        scanTicketUsecaseProvider.overrideWithValue(mockScan),
        voidTicketUsecaseProvider.overrideWithValue(mockVoid),
      ],
      child: const MaterialApp(home: TicketFeatureTestScreen()),
    );
  }

  setUp(() {
    mockGetById = MockGetTicketByIdUsecase();
    mockGetByBooking = MockGetTicketsByBookingUsecase();
    mockScan = MockScanTicketUsecase();
    mockVoid = MockVoidTicketUsecase();
  });

  testWidgets('ticket widget shows initial status', (tester) async {
    await tester.pumpWidget(makeApp());
    expect(find.text('status:initial'), findsOneWidget);
  });

  testWidgets('byId button shows fetchedOne on success', (tester) async {
    when(() => mockGetById('tk1')).thenAnswer((_) async => Right(ticket));

    await tester.pumpWidget(makeApp());
    await tester.tap(find.byKey(const Key('byId')));
    await tester.pumpAndSettle();

    expect(find.text('status:fetchedOne'), findsOneWidget);
  });

  testWidgets('booking button shows fetchedBooking on success', (tester) async {
    when(() => mockGetByBooking('b1')).thenAnswer((_) async => Right([ticket]));

    await tester.pumpWidget(makeApp());
    await tester.tap(find.byKey(const Key('booking')));
    await tester.pumpAndSettle();

    expect(find.text('status:fetchedBooking'), findsOneWidget);
  });

  testWidgets('scan button shows scanned on success', (tester) async {
    when(() => mockScan('qr_123')).thenAnswer((_) async => Right(ticket));

    await tester.pumpWidget(makeApp());
    await tester.tap(find.byKey(const Key('scan')));
    await tester.pumpAndSettle();

    expect(find.text('status:scanned'), findsOneWidget);
  });

  testWidgets('scan button shows error on failure', (tester) async {
    const failure = ApiFailure(message: 'Invalid QR token', statusCode: 400);
    when(() => mockScan('qr_123')).thenAnswer((_) async => const Left(failure));

    await tester.pumpWidget(makeApp());
    await tester.tap(find.byKey(const Key('scan')));
    await tester.pumpAndSettle();

    expect(find.text('status:error'), findsOneWidget);
    expect(find.text('error:Invalid QR token'), findsOneWidget);
  });
}
