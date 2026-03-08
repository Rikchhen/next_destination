import 'package:next_destination/features/auth/data/models/edit_profile_api_model.dart';
import 'package:next_destination/features/auth/data/models/user_api_model.dart';
import 'package:next_destination/features/auth/data/models/user_hive_model.dart';

abstract interface class IUserLocalDatasource {
  Future<UserHiveModel> registerUser(UserHiveModel model);
  Future<UserHiveModel?> loginUser(String email, String password);
  Future<UserHiveModel?> getCurrentUser();
  Future<bool> logout({bool preserveToken = false});

  // Extra Methods: Doesnt Have to be in DOMAIN LAYER repository

  // Method to check if email exixts
  Future<bool> isEmailExists(String email);
}

abstract interface class IUserRemoteDatasource {
  Future<UserApiModel> registerUser(UserApiModel model);
  Future<UserApiModel?> getProfile();
  Future<EditProfileApiModel> editProfile(EditProfileApiModel model);
  Future<UserApiModel?> loginUser(String email, String password);
  Future<bool> logout();
}
