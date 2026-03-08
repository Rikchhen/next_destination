import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/api/api_client.dart';
import 'package:next_destination/core/api/api_endpoint.dart';
import 'package:next_destination/core/services/storage/token_service.dart';
import 'package:next_destination/core/services/storage/user_session_storage.dart';
import 'package:next_destination/features/business/data/datasource/business_datasource.dart';
import 'package:next_destination/features/business/data/model/approve_business_api_model.dart';
import 'package:next_destination/features/business/data/model/business_api_model.dart';
import 'package:next_destination/features/business/data/model/edit_business_profile_api_model.dart';

final businessRemoteDatasourceProvider = Provider<IBusinessRemoteDatasource>((
  ref,
) {
  return BusinessRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

class BusinessRemoteDatasource implements IBusinessRemoteDatasource {
  final ApiClient _apiClient;
  final TokenService _tokenService;
  final UserSessionService _userSessionService;

  BusinessRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenService,
    required UserSessionService userSessionService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService,
       _userSessionService = userSessionService;

  @override
  Future<BusinessApiModel?> loginBusiness(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.businessLogin,
      data: {'email': email, 'password': password},
    );

    if (response.data['success'] == true) {
      final data = response.data['business'] as Map<String, dynamic>;
      final business = BusinessApiModel.fromJson(data);

      await _userSessionService.saveUserSession(
        userId: business.id!,
        email: business.email,
        fullName: business.businessName,
        phoneNumber: business.phoneNumber,
        role: 'business',
      );

      final token = response.data['token'] as String?;
      await _tokenService.saveToken(token!);

      return business;
    }

    return null;
  }

  @override
  Future<BusinessApiModel> registerBusiness(BusinessApiModel model) async {
    final formData = FormData.fromMap({
      'businessName': model.businessName,
      'email': model.email,
      'phoneNumber': model.phoneNumber,
      'password': model.password,
      if (model.address != null) 'address': model.address,
      if (model.profilePicture != null)
        'business-profile-pictures': await MultipartFile.fromFile(
          model.profilePicture!,
          filename: model.profilePicture!.split('/').last,
        ),
    });

    final response = await _apiClient.post(
      ApiEndpoints.businessRegister,
      data: formData,
    );

    if (response.data['success'] == true) {
      final data = response.data['business'] as Map<String, dynamic>;
      final registeredBusiness = BusinessApiModel.fromJson(data);
      return registeredBusiness;
    }

    return model;
  }

  @override
  Future<bool> uploadBusinessDocument(String documentPath) async {
    final formData = FormData.fromMap({
      'document': await MultipartFile.fromFile(
        documentPath,
        filename: documentPath.split('/').last,
      ),
    });

    final token = _tokenService.getToken();

    final response = await _apiClient.post(
      ApiEndpoints.businessUploadDocument,
      data: formData,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data['success'] == true;
  }

  @override
  Future<BusinessApiModel?> getBusinessProfile() async {
    final token = _tokenService.getToken();

    final response = await _apiClient.get(
      ApiEndpoints.businessProfile,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final data = response.data as Map<String, dynamic>;
    final business = BusinessApiModel.fromJson(data);
    return business;
  }

  @override
  Future<EditBusinessProfileApiModel> editBusinessProfile(
    EditBusinessProfileApiModel model,
  ) async {
    final token = _tokenService.getToken();

    final response = await _apiClient.put(
      ApiEndpoints.businessEditProfile,
      data: {
        if (model.businessName != null) 'businessName': model.businessName,
        if (model.email != null) 'email': model.email,
        if (model.phoneNumber != null) 'phoneNumber': model.phoneNumber,
        if (model.address != null) 'address': model.address,
        if (model.profilePicture != null)
          'profilePicture': model.profilePicture,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final data = response.data['business'] as Map<String, dynamic>;
    return EditBusinessProfileApiModel.fromJson(data);
  }

  @override
  Future<List<BusinessApiModel>> getAllBusinesses() async {
    final token = _tokenService.getToken();

    final response = await _apiClient.get(
      ApiEndpoints.adminGetAllBusinesses,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final List<dynamic> data = response.data['businesses'];
    return data
        .map((e) => BusinessApiModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<bool> approveBusiness(
    String businessId,
    ApproveBusinessApiModel model,
  ) async {
    final token = _tokenService.getToken();

    final response = await _apiClient.put(
      ApiEndpoints.adminApproveBusiness(businessId),
      data: model.toJson(),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data['success'] == true;
  }
}
