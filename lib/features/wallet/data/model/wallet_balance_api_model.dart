import 'package:next_destination/features/wallet/domain/entity/wallet_balance_entity.dart';

class WalletBalanceApiModel {
  final double balance;
  final String currency;

  const WalletBalanceApiModel({
    required this.balance,
    required this.currency,
  });

  factory WalletBalanceApiModel.fromJson(Map<String, dynamic> json) {
    return WalletBalanceApiModel(
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      currency: (json['currency'] ?? 'NPR').toString(),
    );
  }

  WalletBalanceEntity toEntity() {
    return WalletBalanceEntity(balance: balance, currency: currency);
  }
}

