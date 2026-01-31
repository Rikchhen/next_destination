import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:next_destination/features/auth/domain/entities/user_entity.dart';
import 'package:next_destination/features/auth/domain/usecases/login_usecase.dart';
import 'package:next_destination/features/auth/domain/usecases/register_usecase.dart';
import 'package:next_destination/features/auth/domain/usecases/edit_profile_usecase.dart';
import 'package:next_destination/features/auth/domain/usecases/get_profile_usecase.dart';
import 'package:next_destination/features/auth/presentation/pages/register_screen.dart';
import 'package:next_destination/features/auth/presentation/viewmodels/user_view_model.dart';
import 'package:next_destination/features/auth/presentation/pages/login_screen.dart';
import 'package:next_destination/features/dashboard/presentation/pages/bottom_screen/home_screen.dart';

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockRegisterUsecase extends Mock implements RegisterUsecase {}

class MockEditProfileUsecase extends Mock implements EditProfileUsecase {}

class MockGetProfileUsecase extends Mock implements GetProfileUsecase {}

class FakeLoginParams extends Fake implements LoginUsecaseParams {}

class FakeRegisterParams extends Fake implements RegisterUsecaseParams {}

class FakeUserEntity extends Fake implements UserEntity {}

void main() {
  late MockLoginUsecase mockLogin;
  late MockRegisterUsecase mockRegister;
  late MockEditProfileUsecase mockEditProfile;
  late MockGetProfileUsecase mockGetProfile;

  ProviderScope makeApp(Widget child) => ProviderScope(
    overrides: [
      loginUsecaseProvider.overrideWithValue(mockLogin),
      registerUsecaseProvider.overrideWithValue(mockRegister),
      editProfileUsecaseProvider.overrideWithValue(mockEditProfile),
      getProfileUsecaseProvider.overrideWithValue(mockGetProfile),
    ],
    child: MaterialApp(home: child),
  );

  setUpAll(() {
    registerFallbackValue(FakeLoginParams());
    registerFallbackValue(FakeRegisterParams());
    registerFallbackValue(FakeUserEntity());
  });

  setUp(() {
    mockLogin = MockLoginUsecase();
    mockRegister = MockRegisterUsecase();
    mockEditProfile = MockEditProfileUsecase();
    mockGetProfile = MockGetProfileUsecase();
  });

  testWidgets('LoginScreen shows title, fields, and buttons', (tester) async {
    await tester.pumpWidget(makeApp(const LoginScreen()));

    expect(find.text('Login'), findsWidgets);
    expect(find.text('Enter your Phone Number'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Tapping "Create an account" navigates to RegisterScreen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen())),
    );

    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Create an account'));
    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);
  });
}
