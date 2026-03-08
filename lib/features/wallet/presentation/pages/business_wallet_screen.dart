import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/utils/snackbar_utils.dart';
import 'package:next_destination/features/wallet/presentation/state/wallet_state.dart';
import 'package:next_destination/features/wallet/presentation/viewmodel/wallet_view_model.dart';

class BusinessWalletScreen extends ConsumerStatefulWidget {
  const BusinessWalletScreen({super.key});

  @override
  ConsumerState<BusinessWalletScreen> createState() => _BusinessWalletScreenState();
}

class _BusinessWalletScreenState extends ConsumerState<BusinessWalletScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(walletViewModelProvider.notifier).loadBusinessWallet(),
    );
  }

  String _fmtDate(DateTime? value) {
    if (value == null) return 'N/A';
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '${value.year}-$month-$day $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(walletViewModelProvider);
    final isLoading = state.status == WalletStatus.loading;

    ref.listen<WalletState>(walletViewModelProvider, (previous, next) {
      if (next.status == WalletStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Wallet'),
        actions: [
          IconButton(
            onPressed: isLoading
                ? null
                : () => ref
                      .read(walletViewModelProvider.notifier)
                      .loadBusinessWallet(page: 1, limit: state.limit),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Current Balance',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    Text(
                      '${state.balance?.currency ?? 'NPR'} ${(state.balance?.balance ?? 0).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading && state.transactions.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.transactions.isEmpty
                ? const Center(child: Text('No transactions found'))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    itemCount: state.transactions.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final tx = state.transactions[index];
                      final isCredit = tx.type == 'credit';

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isCredit
                                ? Colors.green.withOpacity(0.12)
                                : Colors.red.withOpacity(0.12),
                            child: Icon(
                              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                              color: isCredit ? Colors.green : Colors.red,
                            ),
                          ),
                          title: Text(
                            tx.description,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            'Ref: ${tx.reference}\n${_fmtDate(tx.createdAt)}',
                          ),
                          isThreeLine: true,
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${isCredit ? '+' : '-'} ${tx.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: isCredit ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Bal ${tx.balance.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

