import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/features/wallet/domain/usecases/get_business_transactions_usecase.dart';
import 'package:next_destination/features/wallet/domain/usecases/get_business_wallet_balance_usecase.dart';
import 'package:next_destination/features/wallet/presentation/state/wallet_state.dart';

final walletViewModelProvider = NotifierProvider<WalletViewModel, WalletState>(
  () => WalletViewModel(),
);

class WalletViewModel extends Notifier<WalletState> {
  late final GetBusinessWalletBalanceUsecase _getBalanceUsecase;
  late final GetBusinessTransactionsUsecase _getTransactionsUsecase;

  @override
  WalletState build() {
    _getBalanceUsecase = ref.read(getBusinessWalletBalanceUsecaseProvider);
    _getTransactionsUsecase = ref.read(getBusinessTransactionsUsecaseProvider);
    return const WalletState();
  }

  Future<void> loadBusinessWallet({int page = 1, int limit = 10}) async {
    state = state.copyWith(status: WalletStatus.loading);

    final balanceResult = await _getBalanceUsecase.call();
    final txResult = await _getTransactionsUsecase.call(
      GetBusinessTransactionsParams(page: page, limit: limit),
    );

    balanceResult.fold(
      (failure) {
        state = state.copyWith(
          status: WalletStatus.error,
          errorMessage: failure.message,
        );
      },
      (balance) {
        txResult.fold(
          (failure) {
            state = state.copyWith(
              status: WalletStatus.error,
              balance: balance,
              errorMessage: failure.message,
            );
          },
          (pageData) {
            state = state.copyWith(
              status: WalletStatus.loaded,
              balance: balance,
              transactions: pageData.transactions,
              page: pageData.page,
              limit: pageData.limit,
              total: pageData.total,
              pages: pageData.pages,
            );
          },
        );
      },
    );
  }
}

