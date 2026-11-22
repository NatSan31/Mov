import 'dart:async';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../core/services/firebase_service.dart';

class ProductsProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  List<ProductModel> _allProducts = _sampleProducts();
  List<ProductModel> get products => _filteredProducts;

  String _selectedCategory = 'Todos';
  String get selectedCategory => _selectedCategory;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final List<String> categories = const [
    'Todos',
    'Suplementos',
    'Accesorios',
    'Ropa Deportiva',
    'Equipamiento',
  ];

  StreamSubscription<List<ProductModel>>? _productsSubscription;

  ProductsProvider() {
    loadProducts();
  }

  void loadProducts() {
    _isLoading = true;
    notifyListeners();

    if (_firebaseService.hasRealCredentials) {
      // Escuchar en tiempo real desde Firestore
      _productsSubscription?.cancel();
      _productsSubscription = _firebaseService.streamProducts().listen(
        (cloudProducts) {
          if (cloudProducts.isNotEmpty) {
            _allProducts = cloudProducts;
          }
          _isLoading = false;
          notifyListeners();
        },
        onError: (e) {
          debugPrint('[ProductsProvider] Error streaming products: $e');
          _isLoading = false;
          notifyListeners();
        },
      );
    } else {
      // Usar catálogo de muestra sin Firebase
      _allProducts = _sampleProducts();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addProduct(ProductModel product) async {
    try {
      await _firebaseService.saveProduct(product);
      if (!_firebaseService.hasRealCredentials) {
        // En modo offline, agregar localmente
        _allProducts = [..._allProducts, product];
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('[ProductsProvider] Error adding product: $e');
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      await _firebaseService.deleteProduct(productId);
      if (!_firebaseService.hasRealCredentials) {
        _allProducts = _allProducts.where((p) => p.id != productId).toList();
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('[ProductsProvider] Error deleting product: $e');
      return false;
    }
  }

  void selectCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<ProductModel> get _filteredProducts {
    return _allProducts.where((prod) {
      final matchesCategory =
          _selectedCategory == 'Todos' || prod.category == _selectedCategory;
      final matchesSearch =
          prod.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              prod.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _productsSubscription?.cancel();
    super.dispose();
  }

  static List<ProductModel> _sampleProducts() {
    return [
      ProductModel(
        id: 'prod_1',
        name: 'Whey Isolate Protein 100% Ultra (2kg)',
        description:
            'Proteína aislada de suero de leche de rápida absorción con 27g de proteína y 5.5g de BCAAs por porción. Sabor Vainilla Francesa.',
        price: 54.99,
        category: 'Suplementos',
        imageUrl:
            'https://images.unsplash.com/photo-1579722821273-0f6c7d44362f?auto=format&fit=crop&w=600&q=80',
        rating: 4.9,
        stock: 35,
        isFeatured: true,
      ),
      ProductModel(
        id: 'prod_2',
        name: 'Pre-Workout Explosive Energy (30 Serv)',
        description:
            'Fórmula pre-entreno con 300mg de cafeína anhidra, beta-alanina y citrulina malato para máxima vascularización y enfoque mental.',
        price: 38.50,
        category: 'Suplementos',
        imageUrl:
            'https://images.unsplash.com/photo-1593095948071-474c5cc2989d?auto=format&fit=crop&w=600&q=80',
        rating: 4.8,
        stock: 20,
        isFeatured: true,
      ),
      ProductModel(
        id: 'prod_3',
        name: 'Cinturón de Halterofilia Cuero Genuino 10mm',
        description:
            'Soporte lumbar profesional para levantamiento de potencia (Powerlifting) y sentadillas pesadas con hebilla de acero inoxidable.',
        price: 49.00,
        category: 'Accesorios',
        imageUrl:
            'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?auto=format&fit=crop&w=600&q=80',
        rating: 4.7,
        stock: 15,
      ),
      ProductModel(
        id: 'prod_4',
        name: 'Polera Dry-Fit FitPulse Pro Athlete',
        description:
            'Camiseta técnica de compresión transpirable con tecnología anti-olor y corte ergonómico que maximiza la libertad de movimiento.',
        price: 29.99,
        category: 'Ropa Deportiva',
        imageUrl:
            'https://images.unsplash.com/photo-1581655353564-df123a1eb820?auto=format&fit=crop&w=600&q=80',
        rating: 4.6,
        stock: 50,
      ),
      ProductModel(
        id: 'prod_5',
        name: 'Set de Bandas de Resistencia Élite (5 Niveles)',
        description:
            'Bandas de látex natural premium de alta durabilidad con anclaje para puertas, agarraderas acolchadas y bolso de transporte.',
        price: 24.99,
        category: 'Equipamiento',
        imageUrl:
            'https://images.unsplash.com/photo-1598289431512-b97b0917affc?auto=format&fit=crop&w=600&q=80',
        rating: 4.9,
        stock: 40,
      ),
      ProductModel(
        id: 'prod_6',
        name: 'Creatina Monohidratada Creapure (500g)',
        description:
            '100% monohidrato de creatina micronizada de pureza alemana. Aumenta la fuerza muscular explosiva y la masa magra.',
        price: 32.00,
        category: 'Suplementos',
        imageUrl:
            'https://images.unsplash.com/photo-1584017911766-d451b3d0e843?auto=format&fit=crop&w=600&q=80',
        rating: 5.0,
        stock: 60,
        isFeatured: true,
      ),
      ProductModel(
        id: 'prod_7',
        name: 'BCAA 2:1:1 Recovery Complex (400g)',
        description:
            'Aminoácidos de cadena ramificada en proporción óptima para recuperación muscular post-entrenamiento. Sabor Sandía.',
        price: 27.99,
        category: 'Suplementos',
        imageUrl:
            'https://images.unsplash.com/photo-1543362906-acfc16c67564?auto=format&fit=crop&w=600&q=80',
        rating: 4.7,
        stock: 45,
        isFeatured: false,
      ),
      ProductModel(
        id: 'prod_8',
        name: 'Guantes de Entrenamiento Pro Grip',
        description:
            'Guantes de cuero sintético con soporte de muñeca integrado. Diseño anti-deslizante para máximo agarre en barras y mancuernas.',
        price: 19.99,
        category: 'Accesorios',
        imageUrl:
            'https://images.unsplash.com/photo-1592078615290-033ee584e267?auto=format&fit=crop&w=600&q=80',
        rating: 4.5,
        stock: 30,
      ),
      ProductModel(
        id: 'prod_9',
        name: 'Leggings Compression FitPulse Women',
        description:
            'Mallas deportivas de compresión de alta cintura con tecnología de control de humedad y bolsillo lateral.',
        price: 34.99,
        category: 'Ropa Deportiva',
        imageUrl:
            'https://images.unsplash.com/photo-1506629082955-511b1aa562c8?auto=format&fit=crop&w=600&q=80',
        rating: 4.8,
        stock: 25,
      ),
      ProductModel(
        id: 'prod_10',
        name: 'Mancuernas Ajustables Premium 5-25kg',
        description:
            'Sistema de mancuernas ajustables de hierro fundido que reemplaza 9 pares tradicionales. Mecanismo de selección de peso rápido.',
        price: 149.99,
        category: 'Equipamiento',
        imageUrl:
            'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=600&q=80',
        rating: 4.9,
        stock: 10,
        isFeatured: true,
      ),
      ProductModel(
        id: 'prod_11',
        name: 'Omega-3 Fish Oil Ultra Puro (90 caps)',
        description:
            'Aceite de pescado de alta concentración con 1200mg de EPA+DHA por cápsula. Certificado libre de metales pesados.',
        price: 22.50,
        category: 'Suplementos',
        imageUrl:
            'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&w=600&q=80',
        rating: 4.6,
        stock: 80,
      ),
      ProductModel(
        id: 'prod_12',
        name: 'Cuerda de Saltar Speed Rope Pro',
        description:
            'Cuerda de velocidad con rodamientos de precisión y manijas ergonómicas de aluminio. Ideal para crossfit y boxeo.',
        price: 15.99,
        category: 'Equipamiento',
        imageUrl:
            'https://images.unsplash.com/photo-1598971639058-fab3c3109a00?auto=format&fit=crop&w=600&q=80',
        rating: 4.7,
        stock: 55,
      ),
    ];
  }
}
