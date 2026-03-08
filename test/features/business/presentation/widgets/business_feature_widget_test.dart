import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/features/business/domain/entity/business_entity.dart';
import 'package:next_destination/features/business/domain/usecases/approve_business_usecase.dart';
import 'package:next_destination/features/business/domain/usecases/edit_business_profile_usecase.dart';
import 'package:next_destination/features/business/domain/usecases/get_all_businesses_usecase.dart';
import 'package:next_destination/features/business/domain/usecases/get_business_profile_usecase.dart';
import 'package:next_destination/features/business/domain/usecases/login_business_usecase.dart';
import 'package:next_destination/features/business/domain/usecases/register_business_usecase.dart';
import 'package:next_destination/features/business/domain/usecases/upload_business_document_usecase.dart';
import 'package:next_destination/features/business/presentation/viewmodel/business_view_model.dart';

class MockRegisterBusinessUsecase extends Mock implements RegisterBusinessUsecase {}

class MockLoginBusinessUsecase extends Mock implements LoginBusinessUsecase {}

class MockUploadBusinessDocumentUsecase extends Mock
    implements UploadBusinessDocumentUsecase {}

class MockGetBusinessProfileUsecase extends Mock implements GetBusinessProfileUsecase {}

class MockEditBusinessProfileUsecase extends Mock implements EditBusinessProfileUsecase {}

class MockGetAllBusinessesUsecase extends Mock implements GetAllBusinessesUsecase {}

class MockApproveBusinessUsecase extends Mock implements ApproveBusinessUsecase {}

class BusinessFeatureTestScreen extends ConsumerWidget {
  const BusinessFeatureTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(businessViewModelProvider);
    final vm = ref.read(businessViewModelProvider.notifier);

    return Scaffold(
      body: Column(
        children: [
          Text('status:${state.status.name}', key: const Key('status')),
          Text('error:${state.errorMessage ?? ''}', key: const Key('error')),
          ElevatedButton(
            key: const Key('login'),
            onPressed: () =>
                vm.loginBusiness(email: 'biz@next.com', password: 'secret'),
            child: const Text('login'),
          ),
          ElevatedButton(
            key: const Key('profile'),
            onPressed: vm.getBusinessProfile,
            child: const Text('profile'),
          ),
          ElevatedButton(
            key: const Key('all'),
            onPressed: vm.getAllBusinesses,
            child: const Text('all'),
          ),
        ],
      ),
    );
  }
}

void main() {
  late MockRegisterBusinessUsecase mockRegister;
  late MockLoginBusinessUsecase mockLogin;
  late MockUploadBusinessDocumentUsecase mockUpload;
  late MockGetBusinessProfileUsecase mockGetProfile;
  late MockEditBusinessProfileUsecase mockEdit;
  late MockGetAllBusinessesUsecase mockGetAll;
  late MockApproveBusinessUsecase mockApprove;

  const business = BusinessEntity(
    businessId: 'biz1',
    businessName: 'Next Travel',
    email: 'biz@next.com',
    phoneNumber: '9800000000',
    password: null,
    address: 'Kathmandu',
    role: 'business',
    profilePicture: null,
    businessDocument: null,
    businessVerified: true,
    businessStatus: 'approved',
    rejectionReason: null,
  );

  Widget makeApp() {
    return ProviderScope(
      overrides: [
        registerBusinessUsecaseProvider.overrideWithValue(mockRegister),
        loginBusinessUsecaseProvider.overrideWithValue(mockLogin),
        uploadBusinessDocumentUsecaseProvider.overrideWithValue(mockUpload),
        getBusinessProfileUsecaseProvider.overrideWithValue(mockGetProfile),
        editBusinessProfileUsecaseProvider.overrideWithValue(mockEdit),
        getAllBusinessesUsecaseProvider.overrideWithValue(mockGetAll),
        approveBusinessUsecaseProvider.overrideWithValue(mockApprove),
      ],
      child: const MaterialApp(home: BusinessFeatureTestScreen()),
    );
  }

  setUp(() {
    mockRegister = MockRegisterBusinessUsecase();
    mockLogin = MockLoginBusinessUsecase();
    mockUpload = MockUploadBusinessDocumentUsecase();
    mockGetProfile = MockGetBusinessProfileUsecase();
    mockEdit = MockEditBusinessProfileUsecase();
    mockGetAll = MockGetAllBusinessesUsecase();
    mockApprove = MockApproveBusinessUsecase();
  });

  testWidgets('business widget shows initial status', (tester) async {
    await tester.pumpWidget(makeApp());
    expect(find.text('status:initial'), findsOneWidget);
  });

  testWidgets('login button shows authenticated on success', (tester) async {
    const params = LoginBusinessUsecaseParams(
      email: 'biz@next.com',
      password: 'secret',
    );
    when(() => mockLogin(params)).thenAnswer((_) async => const Right(business));

    await tester.pumpWidget(makeApp());
    await tester.tap(find.byKey(const Key('login')));
    await tester.pumpAndSettle();

    expect(find.text('status:authenticated'), findsOneWidget);
  });

  testWidgets('login button shows error on failure', (tester) async {
    const params = LoginBusinessUsecaseParams(
      email: 'biz@next.com',
      password: 'secret',
    );
    const failure = ApiFailure(message: 'Invalid business credentials', statusCode: 401);
    when(() => mockLogin(params)).thenAnswer((_) async => const Left(failure));

    await tester.pumpWidget(makeApp());
    await tester.tap(find.byKey(const Key('login')));
    await tester.pumpAndSettle();

    expect(find.text('status:error'), findsOneWidget);
    expect(find.text('error:Invalid business credentials'), findsOneWidget);
  });

  testWidgets('profile button shows success when profile loads', (tester) async {
    when(() => mockGetProfile()).thenAnswer((_) async => const Right(business));

    await tester.pumpWidget(makeApp());
    await tester.tap(find.byKey(const Key('profile')));
    await tester.pumpAndSettle();

    expect(find.text('status:success'), findsOneWidget);
  });

  testWidgets('all button shows fetchedAll when list loads', (tester) async {
    when(() => mockGetAll()).thenAnswer((_) async => const Right([business]));

    await tester.pumpWidget(makeApp());
    await tester.tap(find.byKey(const Key('all')));
    await tester.pumpAndSettle();

    expect(find.text('status:fetchedAll'), findsOneWidget);
  });
}
