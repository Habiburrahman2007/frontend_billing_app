import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    super.id,
    required super.totalAmount,
    super.note = '',
    required super.items,
    super.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as int?,
      totalAmount: double.parse(json['total_amount'].toString()),
      note: json['note'] as String? ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => TransactionItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'total_amount': totalAmount,
      'note': note,
      'items': items.map((e) => (e as TransactionItemModel).toJson()).toList(),
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
    };
  }

  factory TransactionModel.fromEntity(Transaction entity) {
    return TransactionModel(
      id: entity.id,
      totalAmount: entity.totalAmount,
      note: entity.note,
      items: entity.items.map((e) => TransactionItemModel.fromEntity(e)).toList(),
      createdAt: entity.createdAt,
    );
  }
}

class TransactionItemModel extends TransactionItem {
  const TransactionItemModel({
    required super.productId,
    required super.productName,
    required super.productPrice,
    required super.quantity,
    required super.subtotal,
  });

  factory TransactionItemModel.fromJson(Map<String, dynamic> json) {
    return TransactionItemModel(
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      productPrice: double.parse(json['product_price'].toString()),
      quantity: json['quantity'] as int,
      subtotal: double.parse(json['subtotal'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'product_price': productPrice,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }

  factory TransactionItemModel.fromEntity(TransactionItem entity) {
    return TransactionItemModel(
      productId: entity.productId,
      productName: entity.productName,
      productPrice: entity.productPrice,
      quantity: entity.quantity,
      subtotal: entity.subtotal,
    );
  }
}
