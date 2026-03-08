import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/core/services/connectivity/network_info.dart';
import 'package:next_destination/core/services/hive/hive_service.dart';
import 'package:next_destination/core/services/storage/user_session_storage.dart';
import 'package:next_destination/features/auth/data/datasources/local/user_local_datasource.dart';
import 'package:next_destination/features/auth/data/datasources/remote/user_remote_datasource.dart';
import 'package:next_destination/features/auth/data/datasources/user_datasource.dart';
import 'package:next_destination/features/auth/data/models/edit_profile_api_model.dart';
import 'package:next_destination/features/auth/data/models/user_api_model.dart';
import 'package:next_destination/features/auth/data/models/user_hive_model.dart';
import 'package:next_destination/features/auth/domain/entities/user_entity.dart';
import 'package:next_destination/features/auth/domain/repositories/user_repositroy.dart';
import 'package:next_destination/features/auth/domain/usecases/edit_profile_usecase.dart';

final userRepositoryProvider = Provider<IUserRepository>((ref) {
  final userLocalDatasource = ref.read(userLocalDatasourceProvider);
  final userRemoteDatasource = ref.read(userRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  final hiveService = ref.read(hiveServiceProvider);
  final userSessionService = ref.read(userSessionServiceProvider);
  return UserRepository(
    userLocalDataSource: userLocalDatasource,
    userRemoteDatasource: userRemoteDatasource,
    networkInfo: networkInfo,
    hiveService: hiveService,
    userSessionService: userSessionService,
  );
});

class UserRepository implements IUserRepository {
  final IUserLocalDatasource _userLocalDatasource;
  final IUserRemoteDatasource _userRemoteDatasource;
  final NetworkInfo _networkInfo;
  final HiveService _hiveService;
  final UserSessionService _userSessionService;

  UserRepository({
    required IUserLocalDatasource userLocalDataSource,
    required IUserRemoteDatasource userRemoteDatasource,
    required NetworkInfo networkInfo,
    required HiveService hiveService,
    required UserSessionService userSessionService,
  }) : _userLocalDatasource = userLocalDataSource,
       _userRemoteDatasource = userRemoteDatasource,
       _networkInfo = networkInfo,
       _hiveService = hiveService,
       _userSessionService = userSessionService;

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final user = await _userLocalDatasource.getCurrentUser();
      if (user != null) {
        final userEntity = user.toEntity();
        return Right(userEntity);
      }
      return Left(LocalDatabaseFailure(message: "Could not get current user"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> loginUser(
    String email,
    String password,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _userRemoteDatasource.loginUser(email, password);
        if (apiModel != null) {
          final entity = apiModel.toEntity();
          await _cacheProfile(entity);
          return Right(entity);
        }
        return const Left(ApiFailure(message: "Invalid Credentials"));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? "login Failed",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final user = await _userLocalDatasource.loginUser(email, password);
        if (user != null) {
          final userEntity = user.toEntity();
          return Right(userEntity);
        }
        return Left(LocalDatabaseFailure(message: "Failed to Log In User"));
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> logout({bool preserveToken = false}) async {
    try {
      final result = await _userLocalDatasource.logout(
        preserveToken: preserveToken,
      );
      if (result) return const Right(true);
      return Left(LocalDatabaseFailure(message: "Cannot Log User Out"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> registerUser(UserEntity entity) async {
    if (await _networkInfo.isConnected) {
      try {
        final apimodel = UserApiModel.fromEntity(entity);
        await _userRemoteDatasource.registerUser(apimodel);
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? "Registration Failed",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    } else {
      try {
        // Here We convert the incoming entity into model.
        final model = UserHiveModel.fromEntity(entity);
        await _userLocalDatasource.registerUser(model);
        return Right(true);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> editProfile(
    EditProfileUsecaseParams params,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = EditProfileApiModel(
          fullName: params.fullName,
          username: params.username,
          profilePicture: params.profilePicture,
          email: params.email,
          phoneNumber: params.phoneNumber,
        );
        await _userRemoteDatasource.editProfile(apiModel);
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? "Edit Profile Failed",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: "Internet Required To Edit Profile"));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getProfile() async {
    final userScope = _getUserScope();

    if (await _networkInfo.isConnected) {
      try {
        final user = await _userRemoteDatasource.getProfile();
        debugPrint("User chahi yesto aayo $user");
        if (user != null) {
          final userEntity = user.toEntity();
          await _cacheProfile(userEntity);
          return Right(userEntity);
        }

        final cached = _getCachedProfile(userScope);
        if (cached != null) {
          return Right(cached);
        }

        return Left(ApiFailure(message: "Couldnot get current user"));
      } on DioException catch (e) {
        final cached = _getCachedProfile(userScope);
        if (cached != null) {
          return Right(cached);
        }
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? "Couldnt get user",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        final cached = _getCachedProfile(userScope);
        if (cached != null) {
          return Right(cached);
        }
        return Left(ApiFailure(message: e.toString()));
      }
    }

    try {
      final cached = _getCachedProfile(userScope);
      if (cached != null) {
        return Right(cached);
      }
      return Left(NetworkFailure(message: "No internet and no cached profile found"));
    } catch (_) {
      return Left(NetworkFailure(message: "No internet and no cached profile found"));
    }
  }

  Future<void> _cacheProfile(UserEntity entity) async {
    final userScope = _getUserScope(entity.userId);
    await _hiveService.cacheProfile(
      userScope: userScope,
      profile: _profileToMap(entity),
    );
  }

  UserEntity? _getCachedProfile(String userScope) {
    final cachedProfile = _hiveService.getCachedProfile(userScope);
    if (cachedProfile == null) {
      return null;
    }
    return _userFromMap(cachedProfile);
  }

  String _getUserScope([String? fallbackUserId]) {
    final userId = _userSessionService.getCurrentUserId();
    if (userId != null && userId.isNotEmpty) {
      return userId;
    }
    if (fallbackUserId != null && fallbackUserId.isNotEmpty) {
      return fallbackUserId;
    }
    return 'default';
  }

  Map<String, dynamic> _profileToMap(UserEntity user) {
    return <String, dynamic>{
      'userId': user.userId,
      'fullName': user.fullName,
      'phoneNumber': user.phoneNumber,
      'email': user.email,
      'profilePicture': user.profilePicture,
    };
  }

  UserEntity _userFromMap(Map<String, dynamic> json) {
    return UserEntity(
      userId: json['userId']?.toString(),
      fullName: (json['fullName'] ?? '').toString(),
      phoneNumber: (json['phoneNumber'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      password: null,
      confirmPassword: null,
      profilePicture: json['profilePicture']?.toString(),
    );
  }
}
