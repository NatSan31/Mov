import 'package:flutter/material.dart';
import '../core/services/sensor_service.dart';

class SensorProvider extends ChangeNotifier {
  final SensorService _sensorService = SensorService();

  double _motionIntensity = 15.0; // 0.0 a 100.0
  double get motionIntensity => _motionIntensity;

  bool _shakeRewardAvailable = false;
  bool get shakeRewardAvailable => _shakeRewardAvailable;

  String? _unlockedCouponCode;
  String? get unlockedCouponCode => _unlockedCouponCode;

  int _stepsSimulated = 6420;
  int get stepsSimulated => _stepsSimulated;

  SensorProvider() {
    _initSensors();
  }

  void _initSensors() {
    _sensorService.startListening();

    _sensorService.onIntensityChanged.listen((intensity) {
      _motionIntensity = intensity;
      if (intensity > 30.0) {
        _stepsSimulated += (intensity ~/ 20);
      }
      notifyListeners();
    });

    _sensorService.onShake.listen((_) {
      triggerShakeReward();
    });
  }

  void triggerShakeReward() {
    _shakeRewardAvailable = true;
    _unlockedCouponCode = 'FITPULSE15';
    notifyListeners();
  }

  void dismissShakeReward() {
    _shakeRewardAvailable = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _sensorService.stopListening();
    super.dispose();
  }
}
