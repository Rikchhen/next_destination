import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/services/hive/hive_service.dart';
import 'package:next_destination/core/services/storage/token_service.dart';
import 'package:next_destination/core/services/storage/user_session_storage.dart';
import 'package:next_destination/features/auth/data/datasources/user_datasource.dart';
import 'package:next_destination/features/auth/data/models/user_hive_model.dart';

// Local datasource Provider
final userLocalDatasourceProvider = Provider<UserLocalDatasource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  final userSessionService = ref.read(userSessionServiceProvider);
  final tokenService = ref.read(tokenServiceProvider);

  return UserLocalDatasource(
    hiveService: hiveService,
    userSessionService: userSessionService,
    tokenService: tokenService,
  );
});

class UserLocalDatasource implements IUserLocalDatasource {
  final HiveService _hiveService;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;

  UserLocalDatasource({
    required HiveService hiveService,
    required UserSessionService userSessionService,
    required TokenService tokenService,
  }) : _hiveService = hiveService,
       _tokenService = tokenService,
       _userSessionService = userSessionService;

  @override
  Future<UserHiveModel?> getCurrentUser() async {
    try {
      final currentUserId = _userSessionService.getCurrentUserId();
      if (currentUserId != null && currentUserId.isNotEmpty) {
        final user = _hiveService.getCurrentUser(currentUserId);
        if (user != null) {
          return user;
        }
      }

      final sessionEmail = _userSessionService.getCurrentUserEmail();
      final sessionFullName = _userSessionService.getCurrentUserFullName();
      final sessionPhone = _userSessionService.getCurrentUserPhoneNumber();

      if (sessionEmail == null || sessionFullName == null || sessionPhone == null) {
        return null;
      }

      return UserHiveModel(
        userId: currentUserId,
        fullName: sessionFullName,
        email: sessionEmail,
        phoneNumber: sessionPhone,
        profilePicture: _userSessionService.getCurrentUserProfilePicture(),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> isEmailExists(String email) {
    try {
      final exists = _hiveService.isEmailExists(email);
      return Future.value(exists);
    } catch (e) {
      return Future.value(false);
    }
  }

  @override
  Future<UserHiveModel?> loginUser(String phoneNumber, String password) async {
    try {
      final user = await _hiveService.loginUser(phoneNumber, password);
      // saving User data in Shared Preferences
      if (user != null) {
        await _userSessionService.saveUserSession(
          userId: user.userId!,
          email: user.email,
          fullName: user.fullName,
          phoneNumber: user.phoneNumber,
        );
      }
      return user;
    } catch (e) {
      return Future.value(null);
    }
  }

  @override
  Future<bool> logout({bool preserveToken = false}) async {
    try {
      await _hiveService.logout();

      //keep token for fingerprint login if preserveToken = true
      if (!preserveToken) {
        await _tokenService.removeToken();
      }

      await _userSessionService.clearSession();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<UserHiveModel> registerUser(UserHiveModel model) async {
    return await _hiveService.registerUser(model);
  }
}
