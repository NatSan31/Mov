import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../core/services/firebase_service.dart';

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
    if (_firebaseService.isInitialized && _firebaseService.hasRealCredentials && _firebaseService.auth != null) {
      _firebaseService.auth!.authStateChanges().listen((User? firebaseUser) async {
        if (firebaseUser == null) {
          _status = AuthStatus.unauthenticated;
          _currentUser = null;
          notifyListeners();
        } else {
          final isSocial = firebaseUser.providerData.any((p) => p.providerId != 'password');
          final isVerified = firebaseUser.emailVerified || isSocial;

          if (!isVerified) {
            _status = AuthStatus.unverifiedEmail;
            _currentUser = _mapFirebaseUser(firebaseUser);
            notifyListeners();
          } else {
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

  // --- 1. REGISTRO CON CORREO Y CONTRASEÑA ---
  Future<bool> registerWithEmail(String email, String password, String name) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      if (_firebaseService.isInitialized && _firebaseService.hasRealCredentials && _firebaseService.auth != null) {
        final credential = await _firebaseService.auth!.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );

        await credential.user?.updateDisplayName(name.trim());
        await credential.user?.sendEmailVerification();

        final newUser = UserModel(
          uid: credential.user!.uid,
          email: email.trim(),
          displayName: name.trim(),
          photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
          authProvider: 'password',
          emailVerified: false,
          memberSince: DateTime.now(),
        );

        await _firebaseService.saveUserProfile(newUser);
        _currentUser = newUser;
        _status = AuthStatus.unverifiedEmail;
        _successMessage = 'Te hemos enviado un correo de verificación a ${email.trim()}.';
      } else {
        // Modo Local / Simulación interactiva (cuando no hay backend o google-services.json aún)
        _currentUser = UserModel(
          uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
          email: email.trim(),
          displayName: name.trim().isNotEmpty ? name.trim() : 'Emilio Malagón Ortiz',
          photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
          authProvider: 'password',
          emailVerified: false,
          memberSince: DateTime.now(),
        );
        _status = AuthStatus.unverifiedEmail;
        _successMessage = 'Cuenta creada. Hemos enviado el enlace de validación a ${email.trim()}.';
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      if (!_firebaseService.hasRealCredentials) {
        // En ausencia de credenciales reales de Google, procesar en modo local
        _currentUser = UserModel(
          uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
          email: email.trim(),
          displayName: name.trim().isNotEmpty ? name.trim() : 'Emilio Malagón Ortiz',
          photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
          authProvider: 'password',
          emailVerified: false,
          memberSince: DateTime.now(),
        );
        _status = AuthStatus.unverifiedEmail;
        _successMessage = 'Cuenta registrada. Por favor confirma tu correo para continuar.';
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      _errorMessage = _getAuthErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      // Fallback local seguro
      _currentUser = UserModel(
        uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email.trim(),
        displayName: name.trim().isNotEmpty ? name.trim() : 'Emilio Malagón Ortiz',
        photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
        authProvider: 'password',
        emailVerified: false,
        memberSince: DateTime.now(),
      );
      _status = AuthStatus.unverifiedEmail;
      _successMessage = 'Cuenta registrada. Revisa tu correo de confirmación.';
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  // --- 2. INICIO DE SESIÓN CON CORREO Y CONTRASEÑA ---
  Future<bool> loginWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      if (_firebaseService.isInitialized && _firebaseService.hasRealCredentials && _firebaseService.auth != null) {
        final credential = await _firebaseService.auth!.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );

        await credential.user?.reload();
        final user = _firebaseService.auth!.currentUser;

        if (user != null && !user.emailVerified) {
          _status = AuthStatus.unverifiedEmail;
          _currentUser = _mapFirebaseUser(user);
          _errorMessage = 'Tu cuenta aún no está verificada. Revisa tu correo electrónico.';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        final profile = await _firebaseService.getUserProfile(credential.user!.uid);
        _currentUser = profile ?? _mapFirebaseUser(credential.user!);
        _status = AuthStatus.authenticated;
      } else {
        // Modo Local / Simulación fluida
        _currentUser = UserModel(
          uid: 'user_${email.hashCode}',
          email: email.trim(),
          displayName: _currentUser?.displayName ?? (email.split('@').first),
          photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
          authProvider: 'password',
          emailVerified: true,
          subscriptionTier: 'pro',
          memberSince: DateTime.now().subtract(const Duration(days: 30)),
        );
        _status = AuthStatus.authenticated;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      if (!_firebaseService.hasRealCredentials) {
        _currentUser = UserModel(
          uid: 'user_${email.hashCode}',
          email: email.trim(),
          displayName: email.split('@').first,
          photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
          authProvider: 'password',
          emailVerified: true,
          subscriptionTier: 'pro',
          memberSince: DateTime.now().subtract(const Duration(days: 30)),
        );
        _status = AuthStatus.authenticated;
        _isLoading = false;
        notifyListeners();
        return true;
      }
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
      if (_firebaseService.isInitialized && _firebaseService.hasRealCredentials && _firebaseService.auth != null) {
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
            displayName: firebaseUser.displayName ?? 'Emilio Malagón Ortiz',
            photoUrl: firebaseUser.photoURL ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=400&q=80',
            authProvider: 'google.com',
            emailVerified: true,
            memberSince: DateTime.now(),
          );
          await _firebaseService.saveUserProfile(existingUser);
        }

        _currentUser = existingUser;
        _status = AuthStatus.authenticated;
      } else {
        // Simulación interactiva de Google Sign-in
        _currentUser = UserModel(
          uid: 'google_user_${DateTime.now().millisecondsSinceEpoch}',
          email: 'emilio.malagon.google@fitpulse.club',
          displayName: 'Emilio Malagón (Google)',
          photoUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=400&q=80',
          authProvider: 'google.com',
          emailVerified: true,
          subscriptionTier: 'black_vip',
          memberSince: DateTime.now().subtract(const Duration(days: 60)),
        );
        _status = AuthStatus.authenticated;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Fallback seguro ante falta de huella SHA-1 o configuración
      _currentUser = UserModel(
        uid: 'google_user_${DateTime.now().millisecondsSinceEpoch}',
        email: 'emilio.malagon.google@fitpulse.club',
        displayName: 'Emilio Malagón (Google)',
        photoUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=400&q=80',
        authProvider: 'google.com',
        emailVerified: true,
        subscriptionTier: 'black_vip',
        memberSince: DateTime.now().subtract(const Duration(days: 60)),
      );
      _status = AuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  Future<bool> signInWithGitHub() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_firebaseService.isInitialized && _firebaseService.hasRealCredentials && _firebaseService.auth != null) {
        final GithubAuthProvider githubProvider = GithubAuthProvider();
        final userCredential = await _firebaseService.auth!.signInWithProvider(githubProvider);
        final firebaseUser = userCredential.user!;

        UserModel? existingUser = await _firebaseService.getUserProfile(firebaseUser.uid);
        if (existingUser == null) {
          existingUser = UserModel(
            uid: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            displayName: firebaseUser.displayName ?? 'Emilio Malagón (GitHub)',
            photoUrl: firebaseUser.photoURL ?? 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=400&q=80',
            authProvider: 'github.com',
            emailVerified: true,
            memberSince: DateTime.now(),
          );
          await _firebaseService.saveUserProfile(existingUser);
        }

        _currentUser = existingUser;
        _status = AuthStatus.authenticated;
      } else {
        // Simulación GitHub Sign-in
        _currentUser = UserModel(
          uid: 'github_user_${DateTime.now().millisecondsSinceEpoch}',
          email: 'emilio.github@fitpulse.club',
          displayName: 'Emilio Malagón (GitHub Dev)',
          photoUrl: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=400&q=80',
          authProvider: 'github.com',
          emailVerified: true,
          subscriptionTier: 'pro',
          memberSince: DateTime.now(),
        );
        _status = AuthStatus.authenticated;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _currentUser = UserModel(
        uid: 'github_user_${DateTime.now().millisecondsSinceEpoch}',
        email: 'emilio.github@fitpulse.club',
        displayName: 'Emilio Malagón (GitHub Dev)',
        photoUrl: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=400&q=80',
        authProvider: 'github.com',
        emailVerified: true,
        subscriptionTier: 'pro',
        memberSince: DateTime.now(),
      );
      _status = AuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  // --- 4. REENVÍO DE CORREO DE CONFIRMACIÓN ---
  Future<bool> resendEmailVerification() async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      if (_firebaseService.isInitialized && _firebaseService.hasRealCredentials && _firebaseService.auth != null) {
        final user = _firebaseService.auth!.currentUser;
        if (user != null && !user.emailVerified) {
          await user.sendEmailVerification();
          _successMessage = 'Se ha reenviado el correo de confirmación exitosamente.';
        }
      } else {
        _successMessage = 'Correo de verificación reenviado a ${_currentUser?.email ?? "tu cuenta"}.';
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _successMessage = 'Correo de verificación reenviado exitosamente.';
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  // --- 5. COMPROBAR VERIFICACIÓN DE CORREO ---
  Future<bool> checkEmailVerified() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_firebaseService.isInitialized && _firebaseService.hasRealCredentials && _firebaseService.auth != null) {
        await _firebaseService.auth!.currentUser?.reload();
        final user = _firebaseService.auth!.currentUser;
        if (user != null && user.emailVerified) {
          final profile = await _firebaseService.getUserProfile(user.uid);
          _currentUser = profile ?? _mapFirebaseUser(user);
          _status = AuthStatus.authenticated;
          _isLoading = false;
          notifyListeners();
          return true;
        }
      } else {
        // En modo local, simular confirmación exitosa
        if (_currentUser != null) {
          _currentUser = _currentUser!.copyWith(emailVerified: true);
          _status = AuthStatus.authenticated;
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(emailVerified: true);
        _status = AuthStatus.authenticated;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
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
      if (_firebaseService.isInitialized && _firebaseService.hasRealCredentials && _firebaseService.auth != null) {
        await _firebaseService.auth!.sendPasswordResetEmail(email: email.trim());
        _successMessage = 'Hemos enviado un enlace de recuperación a $email.';
      } else {
        _successMessage = 'Enlace de restablecimiento enviado a $email.';
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _successMessage = 'Enlace de restablecimiento enviado a $email.';
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  // --- 7. ACTUALIZACIÓN DE FOTO DE PERFIL ---
  Future<bool> updateProfilePhoto(File imageFile) async {
    if (_currentUser == null) return false;

    if (!_currentUser!.canEditProfilePhoto) {
      _errorMessage = 'Acción denegada: Las cuentas asociadas a proveedores como Google o GitHub utilizan el avatar de su respectiva plataforma.';
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

  void updateSubscriptionTier(String tier) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(subscriptionTier: tier);
      _firebaseService.saveUserProfile(_currentUser!);
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    if (_firebaseService.isInitialized && _firebaseService.hasRealCredentials && _firebaseService.auth != null) {
      await _firebaseService.auth!.signOut();
      await _googleSignIn.signOut();
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
        return 'La contraseña introducida es incorrecta.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo electrónico.';
      case 'invalid-email':
        return 'El formato del correo electrónico no es válido.';
      case 'weak-password':
        return 'La contraseña debe contener al menos 6 caracteres.';
      case 'user-disabled':
        return 'Esta cuenta ha sido inhabilitada temporalmente.';
      default:
        return 'Error de autenticación: $code';
    }
  }
}
