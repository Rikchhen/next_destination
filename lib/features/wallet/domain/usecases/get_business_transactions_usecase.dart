import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/core/usecases/app_usecase.dart';
import 'package:next_destination/features/wallet/data/repository/wallet_repository.dart';
import 'package:next_destination/features/wallet/domain/entity/wallet_transaction_page_entity.dart';
import 'package:next_destination/features/wallet/domain/repository/wallet_repository.dart';

class GetBusinessTransactionsParams extends Equatable {
  final int page;
  final int limit;

  const GetBusinessTransactionsParams({this.page = 1, this.limit = 10});

  @override
  List<Object?> get props => [page, limit];
}

final getBusinessTransactionsUsecaseProvider =
    Provider<GetBusinessTransactionsUsecase>((ref) {
      return GetBusinessTransactionsUsecase(
        repository: ref.read(walletRepositoryProvider),
      );
    });

class GetBusinessTransactionsUsecase
    implements
        UsecaseWithParams<
          WalletTransactionPageEntity,
          GetBusinessTransactionsParams
        > {
  final IWalletRepository _repository;

  GetBusinessTransactionsUsecase({required IWalletRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, WalletTransactionPageEntity>> call(
    GetBusinessTransactionsParams params,
  ) {
    return _repository.getBusinessTransactions(
      page: params.page,
      limit: params.limit,
    );
  }
}

