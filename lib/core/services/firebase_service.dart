import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
        try {
          await Firebase.initializeApp();
          _hasRealCredentials = true;
          debugPrint('[FirebaseService] Firebase inicializado con credenciales reales.');
        } catch (e) {
          debugPrint('[FirebaseService] No se encontró google-services.json. Inicializando modo contingencia...');
          await Firebase.initializeApp(
            options: const FirebaseOptions(
              apiKey: "AIzaSyFakeKey_FitPulseTesting1234567890",
              appId: "1:123456789012:android:abcdef1234567890",
              messagingSenderId: "123456789012",
              projectId: "fitpulse-testing-app",
              storageBucket: "fitpulse-testing-app.appspot.com",
            ),
          );
          _hasRealCredentials = false;
        }
      }
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _storage = FirebaseStorage.instance;
      _isFirebaseInitialized = true;
    } catch (e) {
      debugPrint('[FirebaseService] Error general en Firebase: $e');
      _isFirebaseInitialized = false;
      _hasRealCredentials = false;
    }
  }

  // --- MÉTODOS DE USUARIO Y PERFIL ---
  Future<void> saveUserProfile(UserModel user) async {
    if (!_isFirebaseInitialized || !_hasRealCredentials || _firestore == null) return;
    try {
      await _firestore!.collection(AppConstants.colUsers).doc(user.uid).set(
        user.toMap(),
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('[FirebaseService] Error saving user profile: $e');
    }
  }

  Future<UserModel?> getUserProfile(String uid) async {
    if (!_isFirebaseInitialized || !_hasRealCredentials || _firestore == null) return null;
    try {
      final doc = await _firestore!.collection(AppConstants.colUsers).doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
    } catch (e) {
      debugPrint('[FirebaseService] Error getting user profile: $e');
    }
    return null;
  }

  Stream<UserModel?> streamUserProfile(String uid) {
    if (!_isFirebaseInitialized || !_hasRealCredentials || _firestore == null) return const Stream.empty();
    return _firestore!.collection(AppConstants.colUsers).doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    });
  }

  // --- FIREBASE STORAGE: SUBIDA DE FOTO DE PERFIL ---
  Future<String> uploadProfileImage(String uid, File imageFile) async {
    if (!_isFirebaseInitialized || !_hasRealCredentials || _storage == null) {
      return 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80';
    }

    try {
      final ref = _storage!.ref().child('profile_pictures').child('$uid.jpg');
      final uploadTask = await ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      await _auth?.currentUser?.updatePhotoURL(downloadUrl);
      await _firestore?.collection(AppConstants.colUsers).doc(uid).update({
        'photoUrl': downloadUrl,
      });

      return downloadUrl;
    } catch (e) {
      debugPrint('[FirebaseService] Error uploading profile image: $e');
      return 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80';
    }
  }

  // --- FIRESTORE: PRODUCTOS EN TIEMPO REAL ---
  Stream<List<ProductModel>> streamProducts() {
    if (!_isFirebaseInitialized || !_hasRealCredentials || _firestore == null) return const Stream.empty();
    return _firestore!.collection(AppConstants.colProducts).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // --- FIRESTORE: ÓRDENES Y TRANSACCIONES ---
  Future<void> saveOrder(OrderModel order) async {
    if (!_isFirebaseInitialized || !_hasRealCredentials || _firestore == null) return;
    try {
      await _firestore!.collection(AppConstants.colOrders).doc(order.id).set(order.toMap());
    } catch (e) {
      debugPrint('[FirebaseService] Error saving order: $e');
    }
  }

  Stream<List<OrderModel>> streamUserOrders(String userId) {
    if (!_isFirebaseInitialized || !_hasRealCredentials || _firestore == null) return const Stream.empty();
    return _firestore!
        .collection(AppConstants.colOrders)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => OrderModel.fromMap(doc.data(), doc.id)).toList());
  }

  // --- FIRESTORE: LOCACIONES DE GIMNASIO EN TIEMPO REAL ---
  Stream<List<GymLocationModel>> streamGymLocations() {
    if (!_isFirebaseInitialized || !_hasRealCredentials || _firestore == null) {
      return const Stream.empty();
    }
    return _firestore!.collection(AppConstants.colLocations).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => GymLocationModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // --- FIRESTORE: GUARDAR PRODUCTO (ADMIN) ---
  Future<void> saveProduct(ProductModel product) async {
    if (!_isFirebaseInitialized || !_hasRealCredentials || _firestore == null) return;
    try {
      if (product.id.isEmpty) {
        await _firestore!.collection(AppConstants.colProducts).add(product.toMap());
      } else {
        await _firestore!.collection(AppConstants.colProducts).doc(product.id).set(product.toMap());
      }
    } catch (e) {
      debugPrint('[FirebaseService] Error saving product: $e');
      rethrow;
    }
  }

  // --- FIRESTORE: ELIMINAR PRODUCTO (ADMIN) ---
  Future<void> deleteProduct(String productId) async {
    if (!_isFirebaseInitialized || !_hasRealCredentials || _firestore == null) return;
    try {
      await _firestore!.collection(AppConstants.colProducts).doc(productId).delete();
    } catch (e) {
      debugPrint('[FirebaseService] Error deleting product: $e');
      rethrow;
    }
  }
}
