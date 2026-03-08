import 'package:dartz/dartz.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/features/business/domain/entity/business_entity.dart';
import 'package:next_destination/features/business/domain/usecases/approve_business_usecase.dart';
import 'package:next_destination/features/business/domain/usecases/edit_business_profile_usecase.dart';
import 'package:next_destination/features/business/domain/usecases/register_business_usecase.dart';

abstract interface class IBusinessRepository {
  Future<Either<Failure, bool>> registerBusiness(
    RegisterBusinessUsecaseParams params,
  );

  Future<Either<Failure, BusinessEntity>> loginBusiness(
    String email,
    String password,
  );

  Future<Either<Failure, bool>> uploadBusinessDocument(String documentPath);

  Future<Either<Failure, BusinessEntity>> getBusinessProfile();

  Future<Either<Failure, bool>> editBusinessProfile(
    EditBusinessProfileUsecaseParams params,
  );

  Future<Either<Failure, List<BusinessEntity>>> getAllBusinesses();

  Future<Either<Failure, bool>> approveBusiness(
    ApproveBusinessUsecaseParams params,
  );
}
