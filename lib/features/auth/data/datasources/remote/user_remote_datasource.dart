import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/api/api_client.dart';
import 'package:next_destination/core/api/api_endpoint.dart';
import 'package:next_destination/core/services/storage/user_session_storage.dart';
import 'package:next_destination/features/auth/data/datasources/user_datasource.dart';
import 'package:next_destination/features/auth/data/models/user_api_model.dart';

// User Remote DAtasource Provider
// Reads API Client provider
final userRemoteDatasourceProvider = Provider<IUserRemoteDatasource>((ref) {
  return UserRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

class UserRemoteDatasource implements IUserRemoteDatasource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;

  UserRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService;

  @override
  Future<UserApiModel?> getCurrentUser() {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }

  @override
  Future<UserApiModel?> loginUser(String phoneNumber, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.userLogin,
      data: {'phoneNumber': phoneNumber, 'password': password},
    );
    if (response.data['success'] == true) {
      final data = response.data['user'] as Map<String, dynamic>;
      final user = UserApiModel.fromJson(data);

      // save user session
      await _userSessionService.saveUserSession(
        userId: user.id!,
        phoneNumber: user.phoneNumber,
        email: user.email,
        fullName: user.fullName,
      );
      return user;
    }
    return null;
  }

  @override
  Future<bool> logout() {
    // TODO: implement logout
    throw UnimplementedError();
  }

  @override
  Future<UserApiModel> registerUser(UserApiModel model) async {
    final response = await _apiClient.post(
      ApiEndpoints.userRegister,
      data: model.toJson(),
    );

    if (response.data['success'] == true) {
      final data = response.data['user'] as Map<String, dynamic>;
      final registeredUser = UserApiModel.fromJson(data);
      return registeredUser;
    }

    return model;
  }
}
