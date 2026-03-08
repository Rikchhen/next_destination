import 'package:next_destination/features/business/data/model/approve_business_api_model.dart';
import 'package:next_destination/features/business/data/model/business_api_model.dart';
import 'package:next_destination/features/business/data/model/edit_business_profile_api_model.dart';

abstract interface class IBusinessRemoteDatasource {
  Future<BusinessApiModel> registerBusiness(BusinessApiModel model);
  Future<BusinessApiModel?> loginBusiness(String email, String password);
  Future<bool> uploadBusinessDocument(String documentPath);
  Future<BusinessApiModel?> getBusinessProfile();
  Future<EditBusinessProfileApiModel> editBusinessProfile(
    EditBusinessProfileApiModel model,
  );
  Future<List<BusinessApiModel>> getAllBusinesses();
  Future<bool> approveBusiness(
    String businessId,
    ApproveBusinessApiModel model,
  );
}
