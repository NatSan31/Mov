import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../core/services/firebase_service.dart';
import '../core/constants/app_constants.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated, unverifiedEmail, authenticating }

class AuthProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthStatus _status = AuthStatus.uninitialized;
  AuthStatus get status => _status;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  AuthProvider() {
    _initAuthListener();
  }

  void _initAuthListener() {
    if (_firebaseService.auth != null) {
      _firebaseService.auth!.authStateChanges().listen((User? firebaseUser) async {
        if (firebaseUser == null) {
          _status = AuthStatus.unauthenticated;
          _currentUser = null;
          notifyListeners();
        } else {
          // Las cuentas de Google o GitHub se consideran verificadas por su propio proveedor OAuth
          final isSocial = firebaseUser.providerData.any((p) => p.providerId != 'password');
          final isVerified = firebaseUser.emailVerified || isSocial;

          if (!isVerified) {
            _status = AuthStatus.unverifiedEmail;
            _currentUser = _mapFirebaseUser(firebaseUser);
            notifyListeners();
          } else {
            // Sincronizar datos reales desde Firestore
            final profile = await _firebaseService.getUserProfile(firebaseUser.uid);
            _currentUser = profile ?? _mapFirebaseUser(firebaseUser);
            _status = AuthStatus.authenticated;
            notifyListeners();
          }
        }
      });
    } else {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  UserModel _mapFirebaseUser(User user) {
    String provider = 'password';
    if (user.providerData.isNotEmpty) {
      provider = user.providerData.first.providerId;
    }

    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? (user.email?.split('@').first ?? 'Atleta FitPulse'),
      photoUrl: user.photoURL ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
      authProvider: provider,
      emailVerified: user.emailVerified || provider != 'password',
      memberSince: DateTime.now(),
    );
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  // --- 1. REGISTRO REAL CON CORREO Y CONTRASEÑA ---
  Future<bool> registerWithEmail(String email, String password, String name) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      if (_firebaseService.auth == null) {
        throw Exception('Servicio de Firebase no disponible.');
      }

      final credential = await _firebaseService.auth!.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(name.trim());

        // Enviar correo de verificación real a través de Firebase Auth
        await user.sendEmailVerification();

        final newUser = UserModel(
          uid: user.uid,
          email: email.trim(),
          displayName: name.trim(),
          photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
          authProvider: 'password',
          emailVerified: false,
          memberSince: DateTime.now(),
        );

        // Guardar documento real del usuario en Firestore
        await _firebaseService.saveUserProfile(newUser);

        _currentUser = newUser;
        _status = AuthStatus.unverifiedEmail;
        _successMessage = 'Te hemos enviado un correo de verificación a ${email.trim()}. Por favor abre tu correo y confirma tu cuenta antes de acceder.';
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getAuthErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al registrar la cuenta: $e';
      notifyListeners();
      return false;
    }
  }

  // --- 2. INICIO DE SESIÓN REAL CON CORREO Y CONTRASEÑA ---
  Future<bool> loginWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      if (_firebaseService.auth == null) {
        throw Exception('Servicio de Firebase no disponible.');
      }

      final credential = await _firebaseService.auth!.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Recargar datos desde los servidores de Google para verificar si ya confirmó el correo
      await credential.user?.reload();
      final user = _firebaseService.auth!.currentUser;

      if (user != null && !user.emailVerified) {
        _status = AuthStatus.unverifiedEmail;
        _currentUser = _mapFirebaseUser(user);
        _errorMessage = 'Tu cuenta aún no está verificada. Revisa tu correo electrónico para confirmar tu identidad.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final profile = await _firebaseService.getUserProfile(credential.user!.uid);
      _currentUser = profile ?? _mapFirebaseUser(credential.user!);
      _status = AuthStatus.authenticated;

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getAuthErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al iniciar sesión: $e';
      notifyListeners();
      return false;
    }
  }

  // --- 3. PROVEEDORES SOCIALES (GOOGLE & GITHUB) ---
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_firebaseService.auth == null) {
        throw Exception('Servicio de Firebase no disponible.');
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseService.auth!.signInWithCredential(credential);
      final firebaseUser = userCredential.user!;

      UserModel? existingUser = await _firebaseService.getUserProfile(firebaseUser.uid);
      if (existingUser == null) {
        existingUser = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? 'Usuario Google',
          photoUrl: firebaseUser.photoURL ?? 'https://lh3.googleusercontent.com/a/default-user',
          authProvider: 'google.com',
          emailVerified: true,
          memberSince: DateTime.now(),
        );
        await _firebaseService.saveUserProfile(existingUser);
      }

      _currentUser = existingUser;
      _status = AuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al iniciar sesión con Google: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGitHub() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_firebaseService.auth == null) {
        throw Exception('Servicio de Firebase no disponible.');
      }

      final GithubAuthProvider githubProvider = GithubAuthProvider();
      final userCredential = await _firebaseService.auth!.signInWithProvider(githubProvider);
      final firebaseUser = userCredential.user!;

      UserModel? existingUser = await _firebaseService.getUserProfile(firebaseUser.uid);
      if (existingUser == null) {
        existingUser = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? 'Usuario GitHub',
          photoUrl: firebaseUser.photoURL ?? 'https://github.com/identicons/user.png',
          authProvider: 'github.com',
          emailVerified: true,
          memberSince: DateTime.now(),
        );
        await _firebaseService.saveUserProfile(existingUser);
      }

      _currentUser = existingUser;
      _status = AuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al iniciar sesión con GitHub: $e';
      notifyListeners();
      return false;
    }
  }

  // --- 4. REENVÍO DE CORREO DE CONFIRMACIÓN REAL ---
  Future<bool> resendEmailVerification() async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final user = _firebaseService.auth?.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        _successMessage = 'Se ha reenviado el correo de confirmación a ${user.email}. Por favor revisa tu bandeja o spam.';
      } else {
        _errorMessage = 'No se encontró un usuario pendiente de verificación.';
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'No se pudo reenviar el correo: $e';
      notifyListeners();
      return false;
    }
  }

  // --- 5. COMPROBAR VERIFICACIÓN DE CORREO ESTRICTA ---
  Future<bool> checkEmailVerified() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _firebaseService.auth?.currentUser;
      if (user != null) {
        // Consultar directamente a los servidores de Firebase
        await user.reload();
        final updatedUser = _firebaseService.auth?.currentUser;

        if (updatedUser != null && updatedUser.emailVerified) {
          // Marcar como verificado en Firestore
          await _firebaseService.firestore
              ?.collection(AppConstants.colUsers)
              .doc(updatedUser.uid)
              .update({'emailVerified': true});

          final profile = await _firebaseService.getUserProfile(updatedUser.uid);
          _currentUser = profile ?? _mapFirebaseUser(updatedUser);
          _status = AuthStatus.authenticated;
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = 'Tu correo aún no ha sido confirmado. Abre el correo que te envió Firebase y haz clic en el enlace de verificación antes de continuar.';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      _isLoading = false;
      _errorMessage = 'No hay sesión de usuario activa.';
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al comprobar verificación: $e';
      notifyListeners();
      return false;
    }
  }

  // --- 6. RECUPERACIÓN DE CONTRASEÑA ---
  Future<bool> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      if (_firebaseService.auth != null) {
        await _firebaseService.auth!.sendPasswordResetEmail(email: email.trim());
        _successMessage = 'Hemos enviado un enlace de recuperación a $email.';
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getAuthErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error enviando enlace de recuperación: $e';
      notifyListeners();
      return false;
    }
  }

  // --- 7. ACTUALIZACIÓN DE FOTO DE PERFIL ---
  Future<bool> updateProfilePhoto(File imageFile) async {
    if (_currentUser == null) return false;

    if (!_currentUser!.canEditProfilePhoto) {
      _errorMessage = 'Acción denegada: Las cuentas asociadas a Google o GitHub utilizan el avatar de su respectiva plataforma.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final downloadUrl = await _firebaseService.uploadProfileImage(_currentUser!.uid, imageFile);
      _currentUser = _currentUser!.copyWith(photoUrl: downloadUrl);
      _successMessage = 'Foto de perfil actualizada correctamente.';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al subir la imagen: $e';
      notifyListeners();
      return false;
    }
  }

  // Actualizar membresía en el perfil tras suscripción
  void updateSubscriptionTier(String tier) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(subscriptionTier: tier);
      _firebaseService.saveUserProfile(_currentUser!);
      notifyListeners();
    }
  }

  // --- CERRAR SESIÓN ---
  Future<void> signOut() async {
    if (_firebaseService.auth != null) {
      await _firebaseService.auth!.signOut();
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
    }
    _status = AuthStatus.unauthenticated;
    _currentUser = null;
    notifyListeners();
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No existe ninguna cuenta registrada con este correo.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'La contraseña introducida es incorrecta o las credenciales no son válidas.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta registrada con este correo electrónico.';
      case 'invalid-email':
        return 'El formato del correo electrónico no es válido.';
      case 'weak-password':
        return 'La contraseña debe contener al menos 6 caracteres.';
      case 'user-disabled':
        return 'Esta cuenta ha sido inhabilitada.';
      default:
        return 'Error de autenticación: $code';
    }
  }
}
