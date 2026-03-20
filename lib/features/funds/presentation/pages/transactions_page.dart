import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_funds/core/utils/currency.dart';
import 'package:management_funds/core/utils/date.dart';
import 'package:management_funds/features/funds/domain/entities/transaction.dart';
import 'package:management_funds/features/funds/presentation/cubit/funds_cubit.dart';
import 'package:management_funds/features/funds/presentation/cubit/funds_state.dart';
import 'package:management_funds/features/funds/presentation/widgets/balance_header.dart';
import 'package:management_funds/core/ui/background.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FundsCubit, FundsState>(
      builder: (context, state) {
        return BankBackground(
          child: Column(
            children: [
              BalanceHeader(balance: state.balance, label: 'Saldo'),
              Expanded(
                child: state.transactions.isEmpty
                    ? const Center(child: Text('Sin transacciones'))
                    : ListView.builder(
                        itemCount: state.transactions.length,
                        itemBuilder: (context, index) {
                          final tx = state.transactions.reversed.toList()[index];
                          final isCredit = tx.type == TransactionType.unsubscribe;
                          final amount = formatCop(tx.delta.abs());
                          final sign = isCredit ? '+' : '-';
                          final color = isCredit
                              ? Colors.green.shade700
                              : Colors.red.shade700;
                          final icon =
                              isCredit ? CupertinoIcons.arrow_down : CupertinoIcons.arrow_up;
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(icon, color: color),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${tx.fundName} • ${tx.category}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${formatDateTime(tx.timestamp)} • Saldo: ${formatCop(tx.balanceAfter)}${tx.notification != null ? ' • Notificación: ${tx.notification == NotificationMethod.email ? 'Email' : 'SMS'}' : ''}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '$sign $amount',
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                    ),
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
      },
    );
  }
}
