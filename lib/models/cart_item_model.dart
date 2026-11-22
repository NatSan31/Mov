import 'product_model.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;

  CartItemModel({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'productName': product.name,
      'price': product.price,
      'imageUrl': product.imageUrl,
      'quantity': quantity,
      'totalPrice': totalPrice,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      product: ProductModel(
        id: map['productId'] ?? '',
        name: map['productName'] ?? '',
        description: '',
        price: (map['price'] as num?)?.toDouble() ?? 0.0,
        category: '',
        imageUrl: map['imageUrl'] ?? '',
      ),
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
    );
  }
}
