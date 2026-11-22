import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/product_model.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../core/services/firebase_service.dart';

class CartProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final List<CartItemModel> _items = [];
  List<CartItemModel> get items => _items;

  String? _appliedCouponCode;
  String? get appliedCouponCode => _appliedCouponCode;

  double _discountPercentage = 0.0;
  double get discountPercentage => _discountPercentage;

  bool _isProcessingPayment = false;
  bool get isProcessingPayment => _isProcessingPayment;

  int get totalItemsCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get discountAmount => subtotal * (_discountPercentage / 100.0);

  double get shippingCost => subtotal > 70.0 || _items.isEmpty ? 0.0 : 5.0;

  double get total => (subtotal - discountAmount + shippingCost).clamp(0.0, double.infinity);

  void addItem(ProductModel product) {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += 1;
    } else {
      _items.add(CartItemModel(product: product, quantity: 1));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void incrementQuantity(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].quantity += 1;
      notifyListeners();
    }
  }

  void decrementQuantity(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity -= 1;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  bool applyCoupon(String coupon) {
    final code = coupon.trim().toUpperCase();
    if (code == 'FITPULSE15' || code == 'FIT15') {
      _appliedCouponCode = code;
      _discountPercentage = 15.0;
      notifyListeners();
      return true;
    } else if (code == 'BLACKVIP20') {
      _appliedCouponCode = code;
      _discountPercentage = 20.0;
      notifyListeners();
      return true;
    }
    return false;
  }

  void removeCoupon() {
    _appliedCouponCode = null;
    _discountPercentage = 0.0;
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _appliedCouponCode = null;
    _discountPercentage = 0.0;
    notifyListeners();
  }

  /// Procesa el pago de la orden y persiste en Firebase Firestore
  Future<OrderModel?> processOrder({
    required String userId,
    required String cardLast4,
    required String cardBrand,
  }) async {
    if (_items.isEmpty) return null;

    _isProcessingPayment = true;
    notifyListeners();

    try {
      // Simulación de latencia de pasarela bancaria / Stripe
      await Future.delayed(const Duration(seconds: 2));

      final order = OrderModel(
        id: const Uuid().v4(),
        userId: userId,
        items: List.from(_items),
        subtotal: subtotal,
        discount: discountAmount,
        total: total,
        createdAt: DateTime.now(),
        status: 'Aprobado y Pagado',
        paymentLast4: cardLast4,
        paymentCardBrand: cardBrand,
      );

      await _firebaseService.saveOrder(order);

      clearCart();
      _isProcessingPayment = false;
      notifyListeners();
      return order;
    } catch (e) {
      _isProcessingPayment = false;
      notifyListeners();
      rethrow;
    }
  }
}
