import 'package:equatable/equatable.dart';

class Fund extends Equatable {
  final int id;
  final String name;
  final int minAmount;
  final String category;

  const Fund({
    required this.id,
    required this.name,
    required this.minAmount,
    required this.category,
  });

  @override
  List<Object?> get props => [id, name, minAmount, category];
}
