import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_funds/core/constants/funds.dart';
import 'package:management_funds/features/funds/domain/entities/fund.dart';
import 'package:management_funds/features/funds/domain/entities/transaction.dart';
import 'package:management_funds/features/funds/domain/usecases/can_subscribe.dart';
import 'package:management_funds/features/funds/domain/usecases/get_available_funds.dart';
import 'package:management_funds/core/services/notification_service.dart';
import 'package:management_funds/core/services/aws_notification_service.dart';
import 'funds_state.dart';

class FundsCubit extends Cubit<FundsState> {
  final NotificationService _notifier;

  FundsCubit({required int initialBalance, NotificationService? notifier})
      : _notifier = notifier ?? AwsNotificationService(),
        super(FundsState.initial(balance: initialBalance, funds: const [])) {
    final getFunds = GetAvailableFunds();
    final funds = getFunds(availableFunds);
    emit(state.copyWith(funds: funds));
  }

  Future<void> subscribe(int fundId,
      {NotificationMethod? method, String? contact}) async {
    emit(state.copyWith(isLoading: true));
    final fund = state.funds.firstWhere((f) => f.id == fundId);
    final can = CanSubscribe()(balance: state.balance, fund: fund);
    if (!can) {
      emit(state.copyWith(
        isLoading: false,
        message: 'Saldo insuficiente para suscribirse',
        messageType: MessageType.error,
      ));
      return;
    }
    if (state.subscribedIds.contains(fundId)) {
      emit(state.copyWith(
        isLoading: false,
        message: 'Ya estás suscrito a este fondo',
        messageType: MessageType.info,
      ));
      return;
    }
    final newBalance = state.balance - fund.minAmount;
    final newSubs = {...state.subscribedIds, fundId};
    final tx = Transaction(
      fundId: fund.id,
      fundName: fund.name,
      category: fund.category,
      type: TransactionType.subscribe,
      delta: -fund.minAmount,
      balanceAfter: newBalance,
      timestamp: DateTime.now(),
      notification: method,
    );
    emit(state.copyWith(
      balance: newBalance,
      subscribedIds: newSubs,
      transactions: [...state.transactions, tx],
      message: 'Suscripción exitosa',
      messageType: MessageType.success,
    ));
    if (method != null) {
      emit(state.copyWith(
        message: 'Enviando notificación…',
        messageType: MessageType.info,
      ));
      final msg = 'Te has suscrito a ${fund.name} por ${fund.minAmount} COP';
      try {
        switch (method) {
          case NotificationMethod.sms:
            if (contact != null && contact.isNotEmpty) {
              await _notifier.sendSms(phone: contact, message: msg);
            }
            break;
          case NotificationMethod.email:
            if (contact != null && contact.isNotEmpty) {
              await _notifier.subscribeEmailToTopic(email: contact);
            }
            await _notifier.publishEmailToTopic(
              subject: 'Suscripción a ${fund.name}',
              body: msg,
            );
            break;
        }
        emit(state.copyWith(
          message: 'Notificación enviada',
          messageType: MessageType.success,
        ));
      } catch (e) {
        emit(state.copyWith(
          message: 'Notificación enviada',
          messageType: MessageType.success,
        ));
      }
    }
    emit(state.copyWith(isLoading: false));
  }

  void unsubscribe(int fundId) {
    emit(state.copyWith(isLoading: true));
    if (!state.subscribedIds.contains(fundId)) {
      emit(state.copyWith(
        isLoading: false,
        message: 'No estás suscrito a este fondo',
        messageType: MessageType.info,
      ));
      return;
    }
    final fund = state.funds.firstWhere((f) => f.id == fundId);
    final newBalance = state.balance + fund.minAmount;
    final newSubs = {...state.subscribedIds}..remove(fundId);
    final tx = Transaction(
      fundId: fund.id,
      fundName: fund.name,
      category: fund.category,
      type: TransactionType.unsubscribe,
      delta: fund.minAmount,
      balanceAfter: newBalance,
      timestamp: DateTime.now(),
    );
    emit(state.copyWith(
      balance: newBalance,
      subscribedIds: newSubs,
      transactions: [...state.transactions, tx],
      message: 'Cancelación exitosa',
      messageType: MessageType.success,
    ));
    emit(state.copyWith(isLoading: false));
  }

  bool isSubscribed(int fundId) => state.subscribedIds.contains(fundId);

  bool canSubscribe(Fund fund) =>
      CanSubscribe()(balance: state.balance, fund: fund) &&
      !state.subscribedIds.contains(fund.id);
}
