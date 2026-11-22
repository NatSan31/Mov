import 'cart_item_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<CartItemModel> items;
  final double subtotal;
  final double discount;
  final double total;
  final DateTime createdAt;
  final String status; // 'Completado', 'Procesando', 'En camino'
  final String paymentLast4;
  final String paymentCardBrand;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    this.discount = 0.0,
    required this.total,
    required this.createdAt,
    this.status = 'Completado',
    required this.paymentLast4,
    required this.paymentCardBrand,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((x) => x.toMap()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'total': total,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'paymentLast4': paymentLast4,
      'paymentCardBrand': paymentCardBrand,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return OrderModel(
      id: docId ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => CartItemModel.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      status: map['status'] ?? 'Completado',
      paymentLast4: map['paymentLast4'] ?? '0000',
      paymentCardBrand: map['paymentCardBrand'] ?? 'Visa',
    );
  }
}
