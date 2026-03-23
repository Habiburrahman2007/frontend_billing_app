import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final int? id;
  final double totalAmount;
  final String note;
  final List<TransactionItem> items;
  final DateTime? createdAt;

  const Transaction({
    this.id,
    required this.totalAmount,
    this.note = '',
    required this.items,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, totalAmount, note, items, createdAt];
}

class TransactionItem extends Equatable {
  final String productId;
  final String productName;
  final double productPrice;
  final int quantity;
  final double subtotal;

  const TransactionItem({
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.quantity,
    required this.subtotal,
  });

  @override
  List<Object?> get props => [productId, productName, productPrice, quantity, subtotal];
}
