import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SensorService {
  static final SensorService _instance = SensorService._internal();
  factory SensorService() => _instance;
  SensorService._internal();

  StreamSubscription<UserAccelerometerEvent>? _accelerometerSubscription;

  // Stream para eventos de "Shake" detectados
  final StreamController<void> _shakeController = StreamController<void>.broadcast();
  Stream<void> get onShake => _shakeController.stream;

  // Stream para magnitudes de movimiento continuo (para el medidor/radar de actividad)
  final StreamController<double> _intensityController = StreamController<double>.broadcast();
  Stream<double> get onIntensityChanged => _intensityController.stream;

  // Parámetros de detección de agitación
  static const double _shakeThreshold = 14.0;
  static const int _shakeCooldownMs = 1500;
  int _lastShakeTime = 0;

  bool _isListening = false;
  bool get isListening => _isListening;

  void startListening() {
    if (_isListening) return;
    _isListening = true;

    try {
      _accelerometerSubscription = userAccelerometerEventStream().listen(
        (UserAccelerometerEvent event) {
          final double magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

          // Emitir intensidad normalizada (0.0 a 100.0)
          final double normalized = (magnitude * 5.0).clamp(0.0, 100.0);
          _intensityController.add(normalized);

          // Detección de agitación con enfriamiento
          final int now = DateTime.now().millisecondsSinceEpoch;
          if (magnitude > _shakeThreshold && (now - _lastShakeTime) > _shakeCooldownMs) {
            _lastShakeTime = now;
            debugPrint('[SensorService] ¡Agitación detectada (Shake Event)! Magnitud: $magnitude');
            _shakeController.add(null);
          }
        },
        onError: (e) {
          debugPrint('[SensorService] Error en stream de acelerómetro: $e');
        },
      );
    } catch (e) {
      debugPrint('[SensorService] Error iniciando acelerómetro: $e');
    }
  }

  void stopListening() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _isListening = false;
  }

  void dispose() {
    stopListening();
    _shakeController.close();
    _intensityController.close();
  }
}
