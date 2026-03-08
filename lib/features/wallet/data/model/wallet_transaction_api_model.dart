import 'package:next_destination/features/wallet/domain/entity/wallet_transaction_entity.dart';

class WalletTransactionApiModel {
  final String? transactionId;
  final String type;
  final double amount;
  final double balance;
  final String reference;
  final String description;
  final DateTime? createdAt;

  const WalletTransactionApiModel({
    this.transactionId,
    required this.type,
    required this.amount,
    required this.balance,
    required this.reference,
    required this.description,
    this.createdAt,
  });

  factory WalletTransactionApiModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionApiModel(
      transactionId: (json['_id'] ?? json['id'])?.toString(),
      type: (json['type'] ?? '').toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      reference: (json['reference'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  WalletTransactionEntity toEntity() {
    return WalletTransactionEntity(
      transactionId: transactionId,
      type: type,
      amount: amount,
      balance: balance,
      reference: reference,
      description: description,
      createdAt: createdAt,
    );
  }

  static List<WalletTransactionEntity> toEntityList(
    List<WalletTransactionApiModel> models,
  ) {
    return models.map((e) => e.toEntity()).toList();
  }
}

