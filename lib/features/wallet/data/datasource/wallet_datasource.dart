import 'package:next_destination/features/wallet/data/model/wallet_balance_api_model.dart';
import 'package:next_destination/features/wallet/data/model/wallet_transaction_page_api_model.dart';

abstract interface class IWalletRemoteDatasource {
  Future<WalletBalanceApiModel> getBusinessWalletBalance();

  Future<WalletTransactionPageApiModel> getBusinessTransactions({
    int page = 1,
    int limit = 10,
  });
}

