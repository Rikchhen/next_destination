import 'package:next_destination/features/wallet/data/model/wallet_transaction_api_model.dart';
import 'package:next_destination/features/wallet/domain/entity/wallet_transaction_page_entity.dart';

class WalletTransactionPageApiModel {
  final List<WalletTransactionApiModel> transactions;
  final int page;
  final int limit;
  final int total;
  final int pages;

  const WalletTransactionPageApiModel({
    required this.transactions,
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory WalletTransactionPageApiModel.fromJson(Map<String, dynamic> json) {
    final txList = (json['data'] as List<dynamic>? ?? [])
        .map((e) => WalletTransactionApiModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final pg = (json['pagination'] as Map<String, dynamic>?) ?? {};

    return WalletTransactionPageApiModel(
      transactions: txList,
      page: (pg['page'] as num?)?.toInt() ?? 1,
      limit: (pg['limit'] as num?)?.toInt() ?? 10,
      total: (pg['total'] as num?)?.toInt() ?? txList.length,
      pages: (pg['pages'] as num?)?.toInt() ?? 1,
    );
  }

  WalletTransactionPageEntity toEntity() {
    return WalletTransactionPageEntity(
      transactions: WalletTransactionApiModel.toEntityList(transactions),
      page: page,
      limit: limit,
      total: total,
      pages: pages,
    );
  }
}

