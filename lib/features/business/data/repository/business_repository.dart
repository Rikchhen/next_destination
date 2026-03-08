import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/core/services/connectivity/network_info.dart';
import 'package:next_destination/core/services/hive/hive_service.dart';
import 'package:next_destination/core/services/storage/user_session_storage.dart';
import 'package:next_destination/features/business/data/datasource/business_datasource.dart';
import 'package:next_destination/features/business/data/datasource/remote/business_remote_datasource.dart';
import 'package:next_destination/features/business/data/model/approve_business_api_model.dart';
import 'package:next_destination/features/business/data/model/business_api_model.dart';
import 'package:next_destination/features/business/data/model/edit_business_profile_api_model.dart';
import 'package:next_destination/features/business/domain/entity/business_entity.dart';
import 'package:next_destination/features/business/domain/repository/business_repository.dart';
import 'package:next_destination/features/business/domain/usecases/approve_business_usecase.dart';
import 'package:next_destination/features/business/domain/usecases/edit_business_profile_usecase.dart';
import 'package:next_destination/features/business/domain/usecases/register_business_usecase.dart';

final businessRepositoryProvider = Provider<IBusinessRepository>((ref) {
  final remoteDatasource = ref.read(businessRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  final hiveService = ref.read(hiveServiceProvider);
  final userSessionService = ref.read(userSessionServiceProvider);

  return BusinessRepository(
    businessRemoteDatasource: remoteDatasource,
    networkInfo: networkInfo,
    hiveService: hiveService,
    userSessionService: userSessionService,
  );
});

class BusinessRepository implements IBusinessRepository {
  final IBusinessRemoteDatasource _businessRemoteDatasource;
  final NetworkInfo _networkInfo;
  final HiveService _hiveService;
  final UserSessionService _userSessionService;

  BusinessRepository({
    required IBusinessRemoteDatasource businessRemoteDatasource,
    required NetworkInfo networkInfo,
    required HiveService hiveService,
    required UserSessionService userSessionService,
  }) : _businessRemoteDatasource = businessRemoteDatasource,
       _networkInfo = networkInfo,
       _hiveService = hiveService,
       _userSessionService = userSessionService;

  @override
  Future<Either<Failure, bool>> registerBusiness(
    RegisterBusinessUsecaseParams params,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = BusinessApiModel(
          businessName: params.businessName,
          email: params.email,
          phoneNumber: params.phoneNumber,
          password: params.password,
          address: params.address,
          role: 'Business',
          profilePicture: params.profilePicture,
          businessDocument: null,
          businessVerified: false,
          businessStatus: 'Pending',
        );

        await _businessRemoteDatasource.registerBusiness(apiModel);
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data['message'] ?? "Business Registration Failed",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(
        NetworkFailure(message: "Internet Required For Registration"),
      );
    }
  }

  @override
  Future<Either<Failure, BusinessEntity>> loginBusiness(
    String email,
    String password,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _businessRemoteDatasource.loginBusiness(
          email,
          password,
        );

        if (apiModel != null) {
          final entity = apiModel.toEntity();
          await _cacheBusinessProfile(entity);
          return Right(entity);
        }

        return const Left(ApiFailure(message: "Invalid Credentials"));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? "Business Login Failed",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: "Internet Required For Login"));
    }
  }

  @override
  Future<Either<Failure, bool>> uploadBusinessDocument(
    String documentPath,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _businessRemoteDatasource.uploadBusinessDocument(
          documentPath,
        );
        return Right(result);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? "Document Upload Failed",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(
        NetworkFailure(message: "Internet Required To Upload Document"),
      );
    }
  }

  @override
  Future<Either<Failure, BusinessEntity>> getBusinessProfile() async {
    if (await _networkInfo.isConnected) {
      try {
        final business = await _businessRemoteDatasource.getBusinessProfile();
        if (business != null) {
          final entity = business.toEntity();
          await _cacheBusinessProfile(entity);
          return Right(entity);
        }

        final cached = _getCachedBusinessProfile();
        if (cached != null) {
          return Right(cached);
        }

        return Left(ApiFailure(message: "Couldnot get business profile"));
      } on DioException catch (e) {
        final cached = _getCachedBusinessProfile();
        if (cached != null) {
          return Right(cached);
        }
        return Left(
          ApiFailure(
            message:
                e.response?.data['message'] ?? "Couldnt get business profile",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        final cached = _getCachedBusinessProfile();
        if (cached != null) {
          return Right(cached);
        }
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      final cached = _getCachedBusinessProfile();
      if (cached != null) {
        return Right(cached);
      }
      return Left(NetworkFailure(message: "No internet and no cached business profile found"));
    }
  }

  @override
  Future<Either<Failure, bool>> editBusinessProfile(
    EditBusinessProfileUsecaseParams params,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = EditBusinessProfileApiModel(
          businessName: params.businessName,
          email: params.email,
          phoneNumber: params.phoneNumber,
          address: params.address,
          profilePicture: params.profilePicture,
        );

        await _businessRemoteDatasource.editBusinessProfile(apiModel);
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data['message'] ?? "Edit Business Profile Failed",
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
  Future<Either<Failure, List<BusinessEntity>>> getAllBusinesses() async {
    if (await _networkInfo.isConnected) {
      try {
        final businesses = await _businessRemoteDatasource.getAllBusinesses();
        return Right(BusinessApiModel.toEntityList(businesses));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? "Couldnt get businesses",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(
        NetworkFailure(message: "Internet Required To Fetch Businesses"),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> approveBusiness(
    ApproveBusinessUsecaseParams params,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = ApproveBusinessApiModel(
          action: params.action,
          reason: params.reason,
        );

        final result = await _businessRemoteDatasource.approveBusiness(
          params.businessId,
          apiModel,
        );

        return Right(result);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? "Business Approval Failed",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: "Internet Required For Approval"));
    }
  }

  String get _businessScope {
    final currentUser = _userSessionService.getCurrentUserId();
    if (currentUser != null && currentUser.isNotEmpty) {
      return currentUser;
    }
    return 'default_business';
  }

  Future<void> _cacheBusinessProfile(BusinessEntity entity) async {
    await _hiveService.cacheBusinessProfile(
      businessScope: _businessScope,
      profile: _businessToMap(entity),
    );
  }

  BusinessEntity? _getCachedBusinessProfile() {
    final raw = _hiveService.getCachedBusinessProfile(_businessScope);
    if (raw == null) {
      return null;
    }
    return _businessFromMap(raw);
  }

  Map<String, dynamic> _businessToMap(BusinessEntity business) {
    return <String, dynamic>{
      'businessId': business.businessId,
      'businessName': business.businessName,
      'email': business.email,
      'phoneNumber': business.phoneNumber,
      'address': business.address,
      'role': business.role,
      'profilePicture': business.profilePicture,
      'businessDocument': business.businessDocument,
      'businessVerified': business.businessVerified,
      'businessStatus': business.businessStatus,
      'rejectionReason': business.rejectionReason,
    };
  }

  BusinessEntity _businessFromMap(Map<String, dynamic> json) {
    return BusinessEntity(
      businessId: json['businessId']?.toString(),
      businessName: (json['businessName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phoneNumber: (json['phoneNumber'] ?? '').toString(),
      password: null,
      address: json['address']?.toString(),
      role: (json['role'] ?? 'Business').toString(),
      profilePicture: json['profilePicture']?.toString(),
      businessDocument: json['businessDocument']?.toString(),
      businessVerified: json['businessVerified'] == true,
      businessStatus: (json['businessStatus'] ?? 'Pending').toString(),
      rejectionReason: json['rejectionReason']?.toString(),
    );
  }
}
