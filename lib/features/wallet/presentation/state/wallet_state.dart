import 'package:equatable/equatable.dart';
import 'package:next_destination/features/wallet/domain/entity/wallet_balance_entity.dart';
import 'package:next_destination/features/wallet/domain/entity/wallet_transaction_entity.dart';

enum WalletStatus {
  initial,
  loading,
  loaded,
  error,
}

class WalletState extends Equatable {
  final WalletStatus status;
  final WalletBalanceEntity? balance;
  final List<WalletTransactionEntity> transactions;
  final int page;
  final int limit;
  final int total;
  final int pages;
  final String? errorMessage;

  const WalletState({
    this.status = WalletStatus.initial,
    this.balance,
    this.transactions = const [],
    this.page = 1,
    this.limit = 10,
    this.total = 0,
    this.pages = 1,
    this.errorMessage,
  });

  WalletState copyWith({
    WalletStatus? status,
    WalletBalanceEntity? balance,
    List<WalletTransactionEntity>? transactions,
    int? page,
    int? limit,
    int? total,
    int? pages,
    String? errorMessage,
  }) {
    return WalletState(
      status: status ?? this.status,
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      pages: pages ?? this.pages,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    balance,
    transactions,
    page,
    limit,
    total,
    pages,
    errorMessage,
  ];
}

