import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_funds/core/utils/currency.dart';
import 'package:management_funds/features/funds/domain/entities/fund.dart';
import 'package:management_funds/features/funds/presentation/cubit/funds_cubit.dart';
import 'package:management_funds/features/funds/presentation/cubit/funds_state.dart';
import 'package:management_funds/features/funds/presentation/widgets/balance_header.dart';
import 'package:management_funds/core/ui/background.dart';

class MyFundsPage extends StatelessWidget {
  const MyFundsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FundsCubit, FundsState>(
      builder: (context, state) {
        final subscribed = state.funds
            .where((f) => state.subscribedIds.contains(f.id))
            .toList();
        return Stack(
          children: [
            BankBackground(
              child: Column(
                children: [
                  BalanceHeader(balance: state.balance, label: 'Saldo'),
                  Expanded(
                    child: subscribed.isEmpty
                        ? const Center(child: Text('No tienes fondos suscritos'))
                        : ListView.builder(
                            itemCount: subscribed.length,
                            itemBuilder: (context, index) {
                              final fund = subscribed[index];
                              return _SubscribedFundTile(fund: fund);
                            },
                          ),
                  ),
                ],
              ),
            ),
            if (state.isLoading)
              Positioned.fill(
                child: AbsorbPointer(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.04),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SubscribedFundTile extends StatelessWidget {
  final Fund fund;
  const _SubscribedFundTile({required this.fund});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FundsCubit>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(CupertinoIcons.creditcard,
                  color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fund.name, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    '${fund.category} • Mínimo ${formatCop(fund.minAmount)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () async {
                if (context.read<FundsCubit>().state.isLoading) return;
                final confirm = await _showUnsubscribeDialog(context);
                if (confirm == true) {
                  cubit.unsubscribe(fund.id);
                }
              },
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool?> _showUnsubscribeDialog(BuildContext context) async {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Confirmar cancelación'),
        content: const Text('¿Deseas cancelar tu participación en este fondo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sí, cancelar'),
          ),
        ],
      );
    },
  );
}
