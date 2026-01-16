import 'package:next_destination/features/auth/data/models/user_api_model.dart';
import 'package:next_destination/features/auth/data/models/user_hive_model.dart';

abstract interface class IUserLocalDatasource {
  Future<UserHiveModel> registerUser(UserHiveModel model);
  Future<UserHiveModel?> loginUser(String phoneNumber, String password);
  Future<UserHiveModel?> getCurrentUser();
  Future<bool> logout();

  // Extra Methods: Doesnt Have to be in DOMAIN LAYER repository

  // Method to check if email exixts
  Future<bool> isEmailExists(String email);
}

abstract interface class IUserRemoteDatasource {
  Future<UserApiModel> registerUser(UserApiModel model);
  Future<UserApiModel?> getCurrentUser();
  Future<UserApiModel?> loginUser(String phoneNumber, String password);
  Future<bool> logout();
}
