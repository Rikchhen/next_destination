import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/features/auth/domain/entities/user_entity.dart';
import 'package:next_destination/features/auth/domain/usecases/edit_profile_usecase.dart';
import 'package:next_destination/features/auth/domain/usecases/get_profile_usecase.dart';
import 'package:next_destination/features/auth/domain/usecases/login_usecase.dart';
import 'package:next_destination/features/auth/domain/usecases/logout_usecase.dart';
import 'package:next_destination/features/auth/domain/usecases/register_usecase.dart';
import 'package:next_destination/features/auth/presentation/state/user_state.dart';
import 'package:next_destination/features/auth/presentation/viewmodels/user_view_model.dart';

class MockRegisterUsecase extends Mock implements RegisterUsecase {}

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockGetProfileUsecase extends Mock implements GetProfileUsecase {}

class MockEditProfileUsecase extends Mock implements EditProfileUsecase {}

class MockLogoutUsecase extends Mock implements LogoutUsecase {}

void main() {
  late MockRegisterUsecase mockRegisterUsecase;
  late MockLoginUsecase mockLoginUsecase;
  late MockGetProfileUsecase mockGetProfileUsecase;
  late MockEditProfileUsecase mockEditProfileUsecase;
  late MockLogoutUsecase mockLogoutUsecase;
  late ProviderContainer container;

  const tUser = UserEntity(
    userId: 'u1',
    fullName: 'Demo User',
    phoneNumber: '9800000000',
    email: 'demo@next.com',
    password: null,
    confirmPassword: null,
  );

  setUp(() {
    mockRegisterUsecase = MockRegisterUsecase();
    mockLoginUsecase = MockLoginUsecase();
    mockGetProfileUsecase = MockGetProfileUsecase();
    mockEditProfileUsecase = MockEditProfileUsecase();
    mockLogoutUsecase = MockLogoutUsecase();

    container = ProviderContainer(
      overrides: [
        registerUsecaseProvider.overrideWithValue(mockRegisterUsecase),
        loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        getProfileUsecaseProvider.overrideWithValue(mockGetProfileUsecase),
        editProfileUsecaseProvider.overrideWithValue(mockEditProfileUsecase),
        logoutUsecaseProvider.overrideWithValue(mockLogoutUsecase),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('initial state is UserStatus.initial', () {
    final state = container.read(userViewModelProvider);
    expect(state.status, UserStatus.initial);
    expect(state.userEntity, isNull);
  });

  test('login success sets authenticated state with user entity', () async {
    const params = LoginUsecaseParams(
      email: 'demo@next.com',
      password: 'secret',
    );
    when(
      () => mockLoginUsecase(params),
    ).thenAnswer((_) async => const Right(tUser));

    await container
        .read(userViewModelProvider.notifier)
        .login(email: 'demo@next.com', password: 'secret');

    final state = container.read(userViewModelProvider);
    expect(state.status, UserStatus.authenticated);
    expect(state.userEntity, tUser);
  });

  test('login failure sets error state', () async {
    const params = LoginUsecaseParams(
      email: 'demo@next.com',
      password: 'wrong',
    );
    const failure = ApiFailure(message: 'Invalid credentials', statusCode: 401);
    when(
      () => mockLoginUsecase(params),
    ).thenAnswer((_) async => const Left(failure));

    await container
        .read(userViewModelProvider.notifier)
        .login(email: 'demo@next.com', password: 'wrong');

    final state = container.read(userViewModelProvider);
    expect(state.status, UserStatus.error);
    expect(state.errorMessage, 'Invalid credentials');
  });

  test('getProfile success sets success state with profile data', () async {
    when(
      () => mockGetProfileUsecase(),
    ).thenAnswer((_) async => const Right(tUser));

    await container.read(userViewModelProvider.notifier).getProfile();

    final state = container.read(userViewModelProvider);
    expect(state.status, UserStatus.success);
    expect(state.userEntity, tUser);
  });
}
