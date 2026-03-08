import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/core/services/connectivity/network_info.dart';
import 'package:next_destination/features/payment/data/datasource/payment_datasource.dart';
import 'package:next_destination/features/payment/data/datasource/remote/payment_remote_datasource.dart';
import 'package:next_destination/features/payment/domain/entity/payment_entity.dart';
import 'package:next_destination/features/payment/domain/entity/payment_initiation_entity.dart';
import 'package:next_destination/features/payment/domain/repository/payment_repository.dart';

final paymentRepositoryProvider = Provider<IPaymentRepository>((ref) {
  return PaymentRepository(
    remoteDatasource: ref.read(paymentRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class PaymentRepository implements IPaymentRepository {
  final IPaymentRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;

  PaymentRepository({
    required IPaymentRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
  }) : _remoteDatasource = remoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, PaymentInitiationEntity>> initiateKhaltiPayment({
    required String bookingId,
    required String returnUrl,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.initiateKhaltiPayment(
          bookingId: bookingId,
          returnUrl: returnUrl,
        );
        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Payment initiation failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(
        NetworkFailure(message: 'Internet Required To Initiate Payment'),
      );
    }
  }

  @override
  Future<Either<Failure, PaymentEntity>> verifyKhaltiPayment({
    required String pidx,
    required String bookingId,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.verifyKhaltiPayment(
          pidx: pidx,
          bookingId: bookingId,
        );
        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Payment verification failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(
        NetworkFailure(message: 'Internet Required To Verify Payment'),
      );
    }
  }

  @override
  Future<Either<Failure, PaymentEntity?>> getPaymentByBookingId(
    String bookingId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDatasource.getPaymentByBookingId(bookingId);
        return Right(result?.toEntity());
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          return const Right(null);
        }

        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to fetch payment',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(
        NetworkFailure(message: 'Internet Required To Fetch Payment'),
      );
    }
  }
}

