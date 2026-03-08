import 'package:equatable/equatable.dart';

class WalletBalanceEntity extends Equatable {
  final double balance;
  final String currency;

  const WalletBalanceEntity({
    required this.balance,
    required this.currency,
  });

  @override
  List<Object?> get props => [balance, currency];
}

