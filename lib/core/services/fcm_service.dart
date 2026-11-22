import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../constants/app_constants.dart';
import 'firebase_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
}

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  FirebaseMessaging? _messaging;

  final StreamController<RemoteMessage> _foregroundMessageStreamController =
      StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get onForegroundMessage => _foregroundMessageStreamController.stream;

  RemoteMessage? _initialMessage;
  RemoteMessage? get initialMessage => _initialMessage;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  Future<void> initialize() async {
    if (!FirebaseService().isInitialized) return;

    try {
      _messaging = FirebaseMessaging.instance;

      // 1. Configurar Background Handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 2. Solicitar permisos de forma asíncrona no bloqueante
      _messaging!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      ).then((settings) {
        debugPrint('[FCM] Permisos: ${settings.authorizationStatus}');
      }).catchError((e) {
        debugPrint('[FCM] Error solicitando permisos: $e');
      });

      // 3. Obtener token con tiempo límite estricto de 2 segundos para evitar bloqueos
      try {
        _fcmToken = await _messaging!.getToken().timeout(
          const Duration(seconds: 2),
          onTimeout: () => null,
        );
      } catch (e) {
        debugPrint('[FCM] Token omitido (modo offline): $e');
      }

      // 4. ESTADO TERMINATED
      try {
        _initialMessage = await _messaging!.getInitialMessage().timeout(
          const Duration(seconds: 1),
          onTimeout: () => null,
        );
      } catch (_) {}

      // 5. ESTADO FOREGROUND
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _foregroundMessageStreamController.add(message);
      });

      // 6. ESTADO BACKGROUND
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('[FCM OpenedApp] Notificación abierta');
      });

      // Suscripción no bloqueante
      subscribeToTopic(AppConstants.topicNovedades);
    } catch (e) {
      debugPrint('[FCMService] Error inicializando FCM: $e');
    }
  }

  Future<bool> subscribeToTopic(String topic) async {
    try {
      if (_messaging != null) {
        await _messaging!.subscribeToTopic(topic).timeout(
          const Duration(seconds: 2),
          onTimeout: () {},
        );
        return true;
      }
    } catch (e) {
      debugPrint('[FCM] Error suscribiéndose a topic $topic: $e');
    }
    return false;
  }

  Future<bool> unsubscribeFromTopic(String topic) async {
    try {
      if (_messaging != null) {
        await _messaging!.unsubscribeFromTopic(topic).timeout(
          const Duration(seconds: 2),
          onTimeout: () {},
        );
        return true;
      }
    } catch (e) {
      debugPrint('[FCM] Error cancelando suscripción: $e');
    }
    return false;
  }

  void dispose() {
    _foregroundMessageStreamController.close();
  }
}
