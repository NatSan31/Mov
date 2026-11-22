import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../firebase_options.dart';
import '../constants/app_constants.dart';
import '../../models/user_model.dart';
import '../../models/product_model.dart';
import '../../models/order_model.dart';
import '../../models/gym_location_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  FirebaseStorage? _storage;

  bool _isFirebaseInitialized = false;
  bool get isInitialized => _isFirebaseInitialized;

  bool _hasRealCredentials = false;
  bool get hasRealCredentials => _hasRealCredentials;

  FirebaseAuth? get auth => _auth;
  FirebaseFirestore? get firestore => _firestore;
  FirebaseStorage? get storage => _storage;

  Future<void> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _storage = FirebaseStorage.instance;
      _isFirebaseInitialized = true;
      _hasRealCredentials = true;
      debugPrint('[FirebaseService] Firebase conectado con éxito a: fitpulse-app-f9977');

      // Auto-sembrado de colecciones iniciales si Firestore está vacío
      _seedInitialDataIfNeeded();
    } catch (e) {
      debugPrint('[FirebaseService] Error conectando con Firebase: $e');
      _isFirebaseInitialized = false;
      _hasRealCredentials = false;
    }
  }

  /// Verifica y puebla automáticamente las colecciones de Firestore si aún no existen
  Future<void> _seedInitialDataIfNeeded() async {
    if (_firestore == null) return;
    try {
      // 1. Sedes de Gimnasio
      final locSnapshot = await _firestore!.collection(AppConstants.colLocations).limit(1).get();
      if (locSnapshot.docs.isEmpty) {
        debugPrint('[FirebaseService] Sembrando sedes en Firestore...');
        final samples = GymLocationModel.getSampleLocations();
        for (final loc in samples) {
          await _firestore!.collection(AppConstants.colLocations).doc(loc.id).set(loc.toMap());
        }
        debugPrint('[FirebaseService] Sedes sembradas en Firestore con éxito.');
      }

      // 2. Catálogo de Productos
      final prodSnapshot = await _firestore!.collection(AppConstants.colProducts).limit(1).get();
      if (prodSnapshot.docs.isEmpty) {
        debugPrint('[FirebaseService] Sembrando catálogo de productos en Firestore...');
        final sampleProducts = [
          ProductModel(
            id: 'prod_1',
            name: 'Whey Isolate Protein 100% Ultra (2kg)',
            description: 'Proteína aislada de suero de leche de rápida absorción con 27g de proteína y 5.5g de BCAAs por porción. Sabor Vainilla Francesa.',
            price: 54.99,
            category: 'Suplementos',
            imageUrl: 'https://images.unsplash.com/photo-1579722821273-0f6c7d44362f?auto=format&fit=crop&w=600&q=80',
            rating: 4.9,
            stock: 35,
            isFeatured: true,
          ),
          ProductModel(
            id: 'prod_2',
            name: 'Pre-Workout Explosive Energy (30 Serv)',
            description: 'Fórmula pre-entreno con 300mg de cafeína anhidra, beta-alanina y citrulina malato para máxima vascularización y enfoque mental.',
            price: 38.50,
            category: 'Suplementos',
            imageUrl: 'https://images.unsplash.com/photo-1593095948071-474c5cc2989d?auto=format&fit=crop&w=600&q=80',
            rating: 4.8,
            stock: 20,
            isFeatured: true,
          ),
          ProductModel(
            id: 'prod_3',
            name: 'Cinturón de Halterofilia Cuero Genuino 10mm',
            description: 'Soporte lumbar profesional para levantamiento de potencia (Powerlifting) y sentadillas pesadas con hebilla de acero inoxidable.',
            price: 49.00,
            category: 'Accesorios',
            imageUrl: 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?auto=format&fit=crop&w=600&q=80',
            rating: 4.7,
            stock: 15,
          ),
          ProductModel(
            id: 'prod_4',
            name: 'Polera Dry-Fit FitPulse Pro Athlete',
            description: 'Camiseta técnica de compresión transpirable con tecnología anti-olor y corte ergonómico que maximiza la libertad de movimiento.',
            price: 29.99,
            category: 'Ropa Deportiva',
            imageUrl: 'https://images.unsplash.com/photo-1581655353564-df123a1eb820?auto=format&fit=crop&w=600&q=80',
            rating: 4.6,
            stock: 50,
          ),
          ProductModel(
            id: 'prod_5',
            name: 'Set de Bandas de Resistencia Élite (5 Niveles)',
            description: 'Bandas de látex natural premium de alta durabilidad con anclaje para puertas, agarraderas acolchadas y bolso de transporte.',
            price: 24.99,
            category: 'Equipamiento',
            imageUrl: 'https://images.unsplash.com/photo-1598289431512-b97b0917affc?auto=format&fit=crop&w=600&q=80',
            rating: 4.9,
            stock: 40,
          ),
          ProductModel(
            id: 'prod_6',
            name: 'Creatina Monohidratada Creapure (500g)',
            description: '100% monohidrato de creatina micronizada de pureza alemana. Aumenta la fuerza muscular explosiva y la masa magra.',
            price: 32.00,
            category: 'Suplementos',
            imageUrl: 'https://images.unsplash.com/photo-1584017911766-d451b3d0e843?auto=format&fit=crop&w=600&q=80',
            rating: 5.0,
            stock: 60,
            isFeatured: true,
          ),
        ];

        for (final p in sampleProducts) {
          await _firestore!.collection(AppConstants.colProducts).doc(p.id).set(p.toMap());
        }
        debugPrint('[FirebaseService] Catálogo de productos sembrado en Firestore con éxito.');
      }
    } catch (e) {
      debugPrint('[FirebaseService] Aviso al inicializar datos en Firestore: $e');
    }
  }

  // --- MÉTODOS DE USUARIO Y PERFIL ---
  Future<void> saveUserProfile(UserModel user) async {
    if (_firestore == null) return;
    try {
      await _firestore!.collection(AppConstants.colUsers).doc(user.uid).set(
        user.toMap(),
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('[FirebaseService] Error guardando perfil: $e');
    }
  }

  Future<UserModel?> getUserProfile(String uid) async {
    if (_firestore == null) return null;
    try {
      final doc = await _firestore!.collection(AppConstants.colUsers).doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
    } catch (e) {
      debugPrint('[FirebaseService] Error obteniendo perfil: $e');
    }
    return null;
  }

  Stream<UserModel?> streamUserProfile(String uid) {
    if (_firestore == null) return const Stream.empty();
    return _firestore!.collection(AppConstants.colUsers).doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    });
  }

  // --- SUBIDA DE FOTO DE PERFIL (Storage nativo con Fallback a Firestore 100% gratuito) ---
  Future<String> uploadProfileImage(String uid, File imageFile) async {
    String? downloadUrl;

    // 1. Intento primario: Firebase Storage oficial
    if (_storage != null) {
      try {
        final ref = _storage!.ref().child('profile_pictures').child('$uid.jpg');
        final uploadTask = await ref.putFile(
          imageFile,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        downloadUrl = await uploadTask.ref.getDownloadURL();
        debugPrint('[FirebaseService] Foto subida exitosamente a Firebase Storage.');
      } catch (storageError) {
        debugPrint('[FirebaseService] Firebase Storage no disponible o requiere plan de pago ($storageError). Activando almacenamiento en Firestore...');
      }
    }

    // 2. Alternativa 100% Gratuita (Firestore Spark sin cobro): Codificación Base64
    if (downloadUrl == null) {
      try {
        final bytes = await imageFile.readAsBytes();
        final base64String = base64Encode(bytes);
        downloadUrl = 'data:image/jpeg;base64,$base64String';
        debugPrint('[FirebaseService] Foto de perfil convertida y almacenada en Firestore sin requerir Storage ni facturación.');
      } catch (e) {
        debugPrint('[FirebaseService] Error en codificación de imagen: $e');
        rethrow;
      }
    }

    // 3. Sincronizar en Firestore y Auth
    try {
      await _firestore?.collection(AppConstants.colUsers).doc(uid).update({
        'photoUrl': downloadUrl,
      });

      if (!downloadUrl.startsWith('data:image')) {
        await _auth?.currentUser?.updatePhotoURL(downloadUrl);
      }
    } catch (e) {
      debugPrint('[FirebaseService] Error actualizando foto en Firestore: $e');
    }

    return downloadUrl;
  }

  // --- FIRESTORE: PRODUCTOS EN TIEMPO REAL ---
  Stream<List<ProductModel>> streamProducts() {
    if (_firestore == null) return const Stream.empty();
    return _firestore!.collection(AppConstants.colProducts).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // --- FIRESTORE: LOCACIONES DE GIMNASIO EN TIEMPO REAL ---
  Stream<List<GymLocationModel>> streamGymLocations() {
    if (_firestore == null) return const Stream.empty();
    return _firestore!.collection(AppConstants.colLocations).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => GymLocationModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // --- FIRESTORE: GUARDAR PRODUCTO (ADMIN) ---
  Future<void> saveProduct(ProductModel product) async {
    if (_firestore == null) return;
    try {
      if (product.id.isEmpty) {
        await _firestore!.collection(AppConstants.colProducts).add(product.toMap());
      } else {
        await _firestore!.collection(AppConstants.colProducts).doc(product.id).set(product.toMap());
      }
    } catch (e) {
      debugPrint('[FirebaseService] Error guardando producto: $e');
      rethrow;
    }
  }

  // --- FIRESTORE: ELIMINAR PRODUCTO (ADMIN) ---
  Future<void> deleteProduct(String productId) async {
    if (_firestore == null) return;
    try {
      await _firestore!.collection(AppConstants.colProducts).doc(productId).delete();
    } catch (e) {
      debugPrint('[FirebaseService] Error eliminando producto: $e');
      rethrow;
    }
  }

  // --- FIRESTORE: ÓRDENES Y TRANSACCIONES REALES ---
  Future<void> saveOrder(OrderModel order) async {
    if (_firestore == null) return;
    try {
      await _firestore!.collection(AppConstants.colOrders).doc(order.id).set(order.toMap());
      debugPrint('[FirebaseService] Orden guardada en Firestore: ${order.id}');
    } catch (e) {
      debugPrint('[FirebaseService] Error guardando orden en Firestore: $e');
      rethrow;
    }
  }

  /// Consulta las órdenes del usuario en Firestore sin requerir índice compuesto
  Stream<List<OrderModel>> streamUserOrders(String userId) {
    if (_firestore == null || userId.isEmpty) return const Stream.empty();
    return _firestore!
        .collection(AppConstants.colOrders)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }
}
