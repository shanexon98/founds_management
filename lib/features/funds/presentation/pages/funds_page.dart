import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:management_funds/core/utils/currency.dart';
import 'package:management_funds/features/funds/domain/entities/fund.dart';
import 'package:management_funds/features/funds/presentation/cubit/funds_cubit.dart';
import 'package:management_funds/features/funds/presentation/cubit/funds_state.dart';
import 'package:management_funds/features/funds/domain/entities/transaction.dart';
import 'package:management_funds/features/funds/domain/usecases/can_subscribe.dart';
import 'package:management_funds/features/funds/presentation/widgets/balance_header.dart';
import 'package:management_funds/core/ui/background.dart';

class FundsPage extends StatelessWidget {
  const FundsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<FundsCubit, FundsState>(
        listener: (context, state) {
          final msg = state.message;
          if (msg != null && msg.isNotEmpty) {
            final type = state.messageType ?? MessageType.info;
            final theme = Theme.of(context);
            final bg = switch (type) {
              MessageType.success => Colors.green.shade600,
              MessageType.error => Colors.red.shade700,
              MessageType.info => theme.colorScheme.primary,
            };
            final fg = Colors.white;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(msg, style: TextStyle(color: fg)),
              backgroundColor: bg,
            ));
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              BankBackground(
                child: Column(
                  children: [
                    BalanceHeader(balance: state.balance),
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.funds.length,
                        itemBuilder: (context, index) {
                          final fund = state.funds[index];
                          return _FundTile(fund: fund);
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
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _FundTile extends StatelessWidget {
  final Fund fund;
  const _FundTile({required this.fund});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FundsCubit>();
    final subscribed = cubit.isSubscribed(fund.id);
    final hasBalance = CanSubscribe()(balance: cubit.state.balance, fund: fund);

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
              child: Icon(CupertinoIcons.chart_pie, color: Theme.of(context).colorScheme.primary),
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
            ElevatedButton(
              onPressed: () async {
                if (context.read<FundsCubit>().state.isLoading) return;
                if (subscribed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ya estás suscrito a este fondo')),
                  );
                  return;
                }
                if (!hasBalance) {
                  await _showInsufficientBalanceDialog(
                    context,
                    fund: fund,
                    currentBalance: cubit.state.balance,
                  );
                  return;
                }
                final selection = await _showSubscribeDialog(context);
                if (selection != null) {
                  await cubit.subscribe(
                    fund.id,
                    method: selection.method,
                    contact: selection.contact,
                  );
                }
              },
              child: Text(subscribed ? 'Suscrito' : 'Suscribirse'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubscribeSelection {
  final NotificationMethod method;
  final String contact;
  _SubscribeSelection(this.method, this.contact);
}

Future<_SubscribeSelection?> _showSubscribeDialog(BuildContext context) async {
  NotificationMethod selected = NotificationMethod.email;
  final contactController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  return showDialog<_SubscribeSelection>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Confirmar suscripción'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Selecciona el método de notificación'),
                  RadioListTile<NotificationMethod>(
                    title: const Text('Email'),
                    value: NotificationMethod.email,
                    groupValue: selected,
                    onChanged: (v) {
                      setState(() => selected = v!);
                      contactController.clear();
                      formKey.currentState?.reset();
                    },
                  ),
                  RadioListTile<NotificationMethod>(
                    title: const Text('SMS'),
                    value: NotificationMethod.sms,
                    groupValue: selected,
                    onChanged: (v) {
                      setState(() => selected = v!);
                      contactController.clear();
                      formKey.currentState?.reset();
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: contactController,
                    keyboardType: selected == NotificationMethod.sms
                        ? TextInputType.phone
                        : TextInputType.emailAddress,
                    inputFormatters: selected == NotificationMethod.sms
                        ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9\+]+'))]
                        : null,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: selected == NotificationMethod.sms
                          ? 'Teléfono (ej: +573001234567)'
                          : 'Email',
                    ),
                    validator: (v) {
                      final value = v?.trim() ?? '';
                      if (selected == NotificationMethod.sms) {
                        return _isValidCoPhone(value) ? null : 'Formato inválido. Usa +57 y 10 dígitos';
                      }
                      return _isValidEmail(value) ? null : 'Email inválido';
                    },
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final ok = formKey.currentState?.validate() ?? false;
              if (!ok) return;
              Navigator.of(context).pop(
                _SubscribeSelection(selected, contactController.text.trim()),
              );
            },
            child: const Text('Confirmar'),
          ),
        ],
      );
    },
  );
}

bool _isValidEmail(String v) {
  final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
  return re.hasMatch(v);
}

bool _isValidCoPhone(String v) {
  final re = RegExp(r'^\+57\d{10}$');
  return re.hasMatch(v);
}
Future<void> _showInsufficientBalanceDialog(
  BuildContext context, {
  required Fund fund,
  required int currentBalance,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      return AlertDialog(
        title: const Text('Saldo insuficiente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: theme.colorScheme.secondary,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'No tienes saldo suficiente para suscribirte a ${fund.name}.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Requieres mínimo ${formatCop(fund.minAmount)} y tu saldo actual es ${formatCop(currentBalance)}.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      );
    },
  );
}
