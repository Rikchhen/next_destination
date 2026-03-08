import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/features/business/domain/usecases/approve_business_usecase.dart';
import 'package:next_destination/features/business/domain/usecases/edit_business_profile_usecase.dart';
import 'package:next_destination/features/business/domain/usecases/get_all_businesses_usecase.dart';
import 'package:next_destination/features/business/domain/usecases/get_business_profile_usecase.dart';
import 'package:next_destination/features/business/domain/usecases/login_business_usecase.dart';
import 'package:next_destination/features/business/domain/usecases/register_business_usecase.dart';
import 'package:next_destination/features/business/domain/usecases/upload_business_document_usecase.dart';
import 'package:next_destination/features/business/presentation/state/business_state.dart';

final businessViewModelProvider =
    NotifierProvider<BusinessViewModel, BusinessState>(
      () => BusinessViewModel(),
    );

class BusinessViewModel extends Notifier<BusinessState> {
  late final RegisterBusinessUsecase _registerBusinessUsecase;
  late final LoginBusinessUsecase _loginBusinessUsecase;
  late final UploadBusinessDocumentUsecase _uploadBusinessDocumentUsecase;
  late final GetBusinessProfileUsecase _getBusinessProfileUsecase;
  late final EditBusinessProfileUsecase _editBusinessProfileUsecase;
  late final GetAllBusinessesUsecase _getAllBusinessesUsecase;
  late final ApproveBusinessUsecase _approveBusinessUsecase;

  @override
  BusinessState build() {
    _registerBusinessUsecase = ref.read(registerBusinessUsecaseProvider);
    _loginBusinessUsecase = ref.read(loginBusinessUsecaseProvider);
    _uploadBusinessDocumentUsecase = ref.read(
      uploadBusinessDocumentUsecaseProvider,
    );
    _getBusinessProfileUsecase = ref.read(getBusinessProfileUsecaseProvider);
    _editBusinessProfileUsecase = ref.read(editBusinessProfileUsecaseProvider);
    _getAllBusinessesUsecase = ref.read(getAllBusinessesUsecaseProvider);
    _approveBusinessUsecase = ref.read(approveBusinessUsecaseProvider);
    return const BusinessState();
  }

  Future<void> registerBusiness({
    required String businessName,
    required String email,
    required String phoneNumber,
    required String password,
    String? address,
    required String profilePicture,
  }) async {
    state = state.copyWith(status: BusinessStatus.loading);

    final params = RegisterBusinessUsecaseParams(
      businessName: businessName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      address: address,
      profilePicture: profilePicture,
    );

    final result = await _registerBusinessUsecase.call(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: BusinessStatus.error,
          errorMessage: failure.message,
        );
      },
      (isRegistered) {
        if (isRegistered) {
          state = state.copyWith(status: BusinessStatus.registered);
        } else {
          state = state.copyWith(
            status: BusinessStatus.error,
            errorMessage: "business registration failed",
          );
        }
      },
    );
  }

  Future<void> loginBusiness({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: BusinessStatus.loading);

    final params = LoginBusinessUsecaseParams(email: email, password: password);

    final result = await _loginBusinessUsecase.call(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: BusinessStatus.error,
          errorMessage: failure.message,
        );
      },
      (businessEntity) {
        state = state.copyWith(
          status: BusinessStatus.authenticated,
          businessEntity: businessEntity,
        );
      },
    );
  }

  Future<void> uploadBusinessDocument({required String documentPath}) async {
    state = state.copyWith(status: BusinessStatus.loading);

    final params = UploadBusinessDocumentUsecaseParams(
      documentPath: documentPath,
    );

    final result = await _uploadBusinessDocumentUsecase.call(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: BusinessStatus.error,
          errorMessage: failure.message,
        );
      },
      (isUploaded) {
        if (isUploaded) {
          state = state.copyWith(status: BusinessStatus.documentUploaded);
        } else {
          state = state.copyWith(
            status: BusinessStatus.error,
            errorMessage: "document upload failed",
          );
        }
      },
    );
  }

  Future<void> getBusinessProfile() async {
    state = state.copyWith(status: BusinessStatus.loading);

    final result = await _getBusinessProfileUsecase.call();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: BusinessStatus.error,
          errorMessage: failure.message,
        );
      },
      (business) {
        state = state.copyWith(
          status: BusinessStatus.success,
          businessEntity: business,
        );
      },
    );
  }

  Future<void> editBusinessProfile({
    String? businessName,
    String? email,
    String? phoneNumber,
    String? address,
    String? profilePicture,
  }) async {
    state = state.copyWith(status: BusinessStatus.loading);

    final params = EditBusinessProfileUsecaseParams(
      businessName: businessName,
      email: email,
      phoneNumber: phoneNumber,
      address: address,
      profilePicture: profilePicture,
    );

    final result = await _editBusinessProfileUsecase.call(params);

    await result.fold(
      (failure) {
        state = state.copyWith(
          status: BusinessStatus.error,
          errorMessage: failure.message,
        );
      },
      (isEdited) async {
        if (isEdited) {
          await getBusinessProfile();
          state = state.copyWith(status: BusinessStatus.edited);
        } else {
          state = state.copyWith(
            status: BusinessStatus.error,
            errorMessage: "edit business profile failed",
          );
        }
      },
    );
  }

  Future<void> getAllBusinesses() async {
    state = state.copyWith(status: BusinessStatus.loading);

    final result = await _getAllBusinessesUsecase.call();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: BusinessStatus.error,
          errorMessage: failure.message,
        );
      },
      (businesses) {
        state = state.copyWith(
          status: BusinessStatus.fetchedAll,
          businesses: businesses,
        );
      },
    );
  }

  Future<void> approveBusiness({
    required String businessId,
    required String action,
    String? reason,
  }) async {
    state = state.copyWith(status: BusinessStatus.loading);

    final params = ApproveBusinessUsecaseParams(
      businessId: businessId,
      action: action,
      reason: reason,
    );

    final result = await _approveBusinessUsecase.call(params);

    await result.fold(
      (failure) {
        state = state.copyWith(
          status: BusinessStatus.error,
          errorMessage: failure.message,
        );
      },
      (isApproved) async {
        if (isApproved) {
          await getAllBusinesses();
          state = state.copyWith(
            status: action == "Approve"
                ? BusinessStatus.approved
                : BusinessStatus.rejected,
          );
        } else {
          state = state.copyWith(
            status: BusinessStatus.error,
            errorMessage: "business approval failed",
          );
        }
      },
    );
  }
}
