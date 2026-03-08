import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/features/auth/domain/entities/user_entity.dart';
import 'package:next_destination/features/auth/domain/repositories/user_repositroy.dart';
import 'package:next_destination/features/auth/domain/usecases/get_profile_usecase.dart';
import 'package:next_destination/features/auth/domain/usecases/login_usecase.dart';

class MockUserRepository extends Mock implements IUserRepository {}

void main() {
  late MockUserRepository repository;
  late LoginUsecase loginUsecase;
  late GetProfileUsecase getProfileUsecase;

  const tUser = UserEntity(
    userId: 'u1',
    fullName: 'Test User',
    phoneNumber: '9800000000',
    email: 'test@next.com',
    password: null,
    confirmPassword: null,
  );

  setUp(() {
    repository = MockUserRepository();
    loginUsecase = LoginUsecase(userRepository: repository);
    getProfileUsecase = GetProfileUsecase(userRepository: repository);
  });

  group('LoginUsecase', () {
    test('returns UserEntity on successful login', () async {
      const params = LoginUsecaseParams(
        email: 'test@next.com',
        password: 'secret',
      );
      when(
        () => repository.loginUser(params.email, params.password),
      ).thenAnswer((_) async => const Right(tUser));

      final result = await loginUsecase(params);

      expect(result, const Right<Failure, UserEntity>(tUser));
    });

    test('returns Failure when repository login fails', () async {
      const params = LoginUsecaseParams(
        email: 'test@next.com',
        password: 'wrong',
      );
      const failure = ApiFailure(message: 'Invalid credentials', statusCode: 401);
      when(
        () => repository.loginUser(params.email, params.password),
      ).thenAnswer((_) async => const Left(failure));

      final result = await loginUsecase(params);

      expect(result, const Left<Failure, UserEntity>(failure));
    });

    test('forwards email and password to repository exactly once', () async {
      const params = LoginUsecaseParams(
        email: 'verify@next.com',
        password: 'pass123',
      );
      when(
        () => repository.loginUser(params.email, params.password),
      ).thenAnswer((_) async => const Right(tUser));

      await loginUsecase(params);

      verify(() => repository.loginUser('verify@next.com', 'pass123')).called(1);
      verifyNoMoreInteractions(repository);
    });
  });

  group('GetProfileUsecase', () {
    test('returns UserEntity when profile fetch succeeds', () async {
      when(() => repository.getProfile()).thenAnswer((_) async => const Right(tUser));

      final result = await getProfileUsecase();

      expect(result, const Right<Failure, UserEntity>(tUser));
    });

    test('returns Failure and calls repository once on profile fetch failure', () async {
      const failure = NetworkFailure(message: 'No internet connection');
      when(
        () => repository.getProfile(),
      ).thenAnswer((_) async => const Left(failure));

      final result = await getProfileUsecase();

      expect(result, const Left<Failure, UserEntity>(failure));
      verify(() => repository.getProfile()).called(1);
      verifyNoMoreInteractions(repository);
    });
  });
}
