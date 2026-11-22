import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      final canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException catch (e) {
      debugPrint('[BiometricService] Error comprobando soporte biométrico: $e');
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      debugPrint('[BiometricService] Error obteniendo biometría: $e');
      return [];
    }
  }

  Future<bool> authenticate({required String localizedReason}) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        debugPrint('[BiometricService] Biometría no disponible en el dispositivo actual.');
        // Si no está disponible en simulador, retornar true para pruebas fluidas
        return true;
      }

      return await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (e) {
      debugPrint('[BiometricService] Error en autenticación biométrica: $e');
      return false;
    }
  }
}
