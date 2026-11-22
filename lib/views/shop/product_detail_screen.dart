import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/cached_network_image_wrapper.dart';
import '../../widgets/custom_button.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: cartProvider.totalItemsCount > 0,
              label: Text('${cartProvider.totalItemsCount}'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen principal en gran formato con caché offline
                  SizedBox(
                    height: 280,
                    width: double.infinity,
                    child: CachedImageWrapper(
                      imageUrl: product.imageUrl,
                      width: double.infinity,
                      height: 280,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                product.category.toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.primaryLight,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star, color: AppColors.accent, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  '${product.rating} (128 reseñas)',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          product.name,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '\$${product.price.toStringAsFixed(2)} USD',
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Colors.white12),
                        const SizedBox(height: 16),
                        const Text(
                          'DESCRIPCIÓN DEL PRODUCTO',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.description,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Icon(Icons.check_circle_outline, color: AppColors.secondary, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'En stock disponible: ${product.stock} unidades',
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: const [
                            Icon(Icons.local_shipping_outlined, color: AppColors.secondary, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Envío exprés disponible a domicilio o retiro en sede',
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Barra inferior con botón de agregar al carrito
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color ?? AppColors.darkCard,
              border: const Border(top: BorderSide(color: Colors.white12)),
            ),
            child: SafeArea(
              child: CustomButton(
                text: 'AGREGAR AL CARRITO',
                icon: Icons.add_shopping_cart,
                onPressed: () {
                  cartProvider.addItem(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} agregado al carrito'),
                      action: SnackBarAction(
                        label: 'IR AL CARRITO',
                        textColor: Colors.white,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const CartScreen()),
                          );
                        },
                      ),
                      backgroundColor: AppColors.secondary,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
