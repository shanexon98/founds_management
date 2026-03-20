import 'package:equatable/equatable.dart';
import 'package:management_funds/features/funds/domain/entities/fund.dart';
import 'package:management_funds/features/funds/domain/entities/transaction.dart';

enum MessageType { success, error, info }

class FundsState extends Equatable {
  final int balance;
  final List<Fund> funds;
  final Set<int> subscribedIds;
  final List<Transaction> transactions;
  final String? message;
  final MessageType? messageType;
  final bool isLoading;

  const FundsState({
    required this.balance,
    required this.funds,
    required this.subscribedIds,
    required this.transactions,
    this.message,
    this.messageType,
    this.isLoading = false,
  });

  factory FundsState.initial({
    required int balance,
    required List<Fund> funds,
  }) {
    return FundsState(
      balance: balance,
      funds: funds,
      subscribedIds: {},
      transactions: const [],
      isLoading: false,
    );
  }

  FundsState copyWith({
    int? balance,
    List<Fund>? funds,
    Set<int>? subscribedIds,
    List<Transaction>? transactions,
    String? message,
    MessageType? messageType,
    bool? isLoading,
  }) {
    return FundsState(
      balance: balance ?? this.balance,
      funds: funds ?? this.funds,
      subscribedIds: subscribedIds ?? this.subscribedIds,
      transactions: transactions ?? this.transactions,
      message: message,
      messageType: messageType,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [balance, funds, subscribedIds, transactions, message, messageType, isLoading];
}
