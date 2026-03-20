enum TransactionType { subscribe, unsubscribe }
enum NotificationMethod { email, sms }

class Transaction {
  final int fundId;
  final String fundName;
  final String category;
  final TransactionType type;
  final int delta;
  final int balanceAfter;
  final DateTime timestamp;
  final NotificationMethod? notification;

  const Transaction({
    required this.fundId,
    required this.fundName,
    required this.category,
    required this.type,
    required this.delta,
    required this.balanceAfter,
    required this.timestamp,
    this.notification,
  });
}
