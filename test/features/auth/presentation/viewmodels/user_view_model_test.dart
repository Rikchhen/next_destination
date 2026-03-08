import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/features/auth/domain/entities/user_entity.dart';
import 'package:next_destination/features/auth/domain/usecases/edit_profile_usecase.dart';
import 'package:next_destination/features/auth/domain/usecases/get_profile_usecase.dart';
import 'package:next_destination/features/auth/domain/usecases/login_usecase.dart';
import 'package:next_destination/features/auth/domain/usecases/register_usecase.dart';
import 'package:next_destination/features/auth/presentation/state/user_state.dart';
import 'package:next_destination/features/auth/presentation/viewmodels/user_view_model.dart';

class MockRegisterUsecase extends Mock implements RegisterUsecase {}

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockGetProfileUsecase extends Mock implements GetProfileUsecase {}

class MockEditProfileUsecase extends Mock implements EditProfileUsecase {}

class FakeLoginParams extends Fake implements LoginUsecaseParams {}

class FakeRegisterParams extends Fake implements RegisterUsecaseParams {}

class FakeUserEntity extends Fake implements UserEntity {}

class UserAuthScreen extends ConsumerWidget {
  const UserAuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Auth Test UI')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Status: ${state.status.name}'),
          if (state.errorMessage != null)
            Text('Error: ${state.errorMessage}', key: const Key('errorText')),
          ElevatedButton(
            key: const Key('loginButton'),
            onPressed: () {
              ref
                  .read(userViewModelProvider.notifier)
                  .login(email: '9800000000', password: '123456');
            },
            child: const Text('Login'),
          ),
          ElevatedButton(
            key: const Key('registerButton'),
            onPressed: () {
              ref
                  .read(userViewModelProvider.notifier)
                  .register(
                    fullName: 'User',
                    email: 'user@test.com',
                    password: '123456',
                    confirmPassword: '123456',
                    phoneNumber: '9800000000',
                  );
            },
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }
}

void main() {
  late MockRegisterUsecase mockRegister;
  late MockLoginUsecase mockLogin;
  late MockGetProfileUsecase mockGetProfile;
  late MockEditProfileUsecase mockEditProfile;

  ProviderScope makeApp(Widget child) => ProviderScope(
    overrides: [
      registerUsecaseProvider.overrideWithValue(mockRegister),
      loginUsecaseProvider.overrideWithValue(mockLogin),
      getProfileUsecaseProvider.overrideWithValue(mockGetProfile),
      editProfileUsecaseProvider.overrideWithValue(mockEditProfile),
    ],
    child: MaterialApp(home: child),
  );

  setUpAll(() {
    registerFallbackValue(FakeLoginParams());
    registerFallbackValue(FakeRegisterParams());
  });

  setUp(() {
    mockRegister = MockRegisterUsecase();
    mockLogin = MockLoginUsecase();
    mockGetProfile = MockGetProfileUsecase();
    mockEditProfile = MockEditProfileUsecase();
  });

  testWidgets('UI shows initial state text', (tester) async {
    await tester.pumpWidget(makeApp(const UserAuthScreen()));

    expect(find.textContaining('initial'), findsOneWidget);
  });

  testWidgets('Tapping Login first shows loading then authenticated', (
    tester,
  ) async {
    when(() => mockLogin(any())).thenAnswer((_) async {
      await Future.delayed(const Duration(milliseconds: 100));
      return Right(FakeUserEntity());
    });

    await tester.pumpWidget(makeApp(const UserAuthScreen()));

    await tester.tap(find.byKey(const Key('loginButton')));

    await tester.pump();

    expect(find.textContaining('loading'), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.textContaining('authenticated'), findsOneWidget);
  });

  testWidgets('Successful login shows authenticated state', (tester) async {
    when(
      () => mockLogin(any()),
    ).thenAnswer((_) async => Right(FakeUserEntity()));

    await tester.pumpWidget(makeApp(const UserAuthScreen()));

    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle();

    expect(find.textContaining('authenticated'), findsOneWidget);
  });

  testWidgets('Successful register shows registered state', (tester) async {
    when(
      () => mockRegister.call(any()),
    ).thenAnswer((_) async => const Right(true));

    await tester.pumpWidget(makeApp(const UserAuthScreen()));

    await tester.tap(find.byKey(const Key('registerButton')));
    await tester.pumpAndSettle();

    expect(find.textContaining('registered'), findsOneWidget);
  });

  testWidgets('Login failure shows error text on UI', (tester) async {
    when(() => mockLogin(any())).thenAnswer(
      (_) async => const Left(ApiFailure(message: 'Invalid credentials')),
    );

    await tester.pumpWidget(makeApp(const UserAuthScreen()));

    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('errorText')), findsOneWidget);
    expect(find.textContaining('Invalid credentials'), findsOneWidget);
  });
}
