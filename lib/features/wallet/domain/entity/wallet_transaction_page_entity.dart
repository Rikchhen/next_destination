import 'package:equatable/equatable.dart';
import 'package:next_destination/features/wallet/domain/entity/wallet_transaction_entity.dart';

class WalletTransactionPageEntity extends Equatable {
  final List<WalletTransactionEntity> transactions;
  final int page;
  final int limit;
  final int total;
  final int pages;

  const WalletTransactionPageEntity({
    required this.transactions,
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  @override
  List<Object?> get props => [transactions, page, limit, total, pages];
}

