import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/core/usecases/app_usecase.dart';
import 'package:next_destination/features/wallet/data/repository/wallet_repository.dart';
import 'package:next_destination/features/wallet/domain/entity/wallet_balance_entity.dart';
import 'package:next_destination/features/wallet/domain/repository/wallet_repository.dart';

final getBusinessWalletBalanceUsecaseProvider =
    Provider<GetBusinessWalletBalanceUsecase>((ref) {
      return GetBusinessWalletBalanceUsecase(
        repository: ref.read(walletRepositoryProvider),
      );
    });

class GetBusinessWalletBalanceUsecase
    implements UsecaseWithoutParams<WalletBalanceEntity> {
  final IWalletRepository _repository;

  GetBusinessWalletBalanceUsecase({required IWalletRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, WalletBalanceEntity>> call() {
    return _repository.getBusinessWalletBalance();
  }
}

