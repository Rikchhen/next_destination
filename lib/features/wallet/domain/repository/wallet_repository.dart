import 'package:dartz/dartz.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/features/wallet/domain/entity/wallet_balance_entity.dart';
import 'package:next_destination/features/wallet/domain/entity/wallet_transaction_page_entity.dart';

abstract interface class IWalletRepository {
  Future<Either<Failure, WalletBalanceEntity>> getBusinessWalletBalance();

  Future<Either<Failure, WalletTransactionPageEntity>> getBusinessTransactions({
    int page = 1,
    int limit = 10,
  });
}

