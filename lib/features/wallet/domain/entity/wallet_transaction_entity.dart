import 'package:equatable/equatable.dart';

class WalletTransactionEntity extends Equatable {
  final String? transactionId;
  final String type;
  final double amount;
  final double balance;
  final String reference;
  final String description;
  final DateTime? createdAt;

  const WalletTransactionEntity({
    this.transactionId,
    required this.type,
    required this.amount,
    required this.balance,
    required this.reference,
    required this.description,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    transactionId,
    type,
    amount,
    balance,
    reference,
    description,
    createdAt,
  ];
}

