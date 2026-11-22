import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../core/services/fcm_service.dart';

class NotificationTopicItem {
  final String key;
  final String title;
  final String description;
  bool isSubscribed;

  NotificationTopicItem({
    required this.key,
    required this.title,
    required this.description,
    this.isSubscribed = false,
  });
}

class NotificationProvider extends ChangeNotifier {
  final FCMService _fcmService = FCMService();

  RemoteMessage? _latestForegroundNotification;
  RemoteMessage? get latestForegroundNotification => _latestForegroundNotification;

  bool _showInAppBanner = false;
  bool get showInAppBanner => _showInAppBanner;

  final List<NotificationTopicItem> _topics = [
    NotificationTopicItem(
      key: AppConstants.topicPromociones,
      title: 'Promociones y Descuentos Pro Shop',
      description: 'Ofertas relámpago en suplementación, ropa deportiva y accesorios.',
      isSubscribed: true,
    ),
    NotificationTopicItem(
      key: AppConstants.topicNovedades,
      title: 'Novedades y Anuncios del Club',
      description: 'Nuevas clases grupales, aperturas de sedes y actualizaciones.',
      isSubscribed: true,
    ),
    NotificationTopicItem(
      key: AppConstants.topicEventos,
      title: 'Eventos y Torneos Fitness',
      description: 'Convocatorias a maratones, retos CrossFit y competencias.',
      isSubscribed: false,
    ),
    NotificationTopicItem(
      key: AppConstants.topicConsejosSalud,
      title: 'Consejos de Nutrición y Salud',
      description: 'Tips diarios de entrenadores certificados y nutriólogos.',
      isSubscribed: false,
    ),
  ];

  List<NotificationTopicItem> get topics => _topics;

  NotificationProvider() {
    _initListener();
    _loadSubscribedTopics();
  }

  void _initListener() {
    _fcmService.onForegroundMessage.listen((RemoteMessage message) {
      _latestForegroundNotification = message;
      _showInAppBanner = true;
      notifyListeners();

      // Ocultar banner automáticamente después de 6 segundos
      Future.delayed(const Duration(seconds: 6), () {
        dismissBanner();
      });
    });
  }

  void dismissBanner() {
    _showInAppBanner = false;
    notifyListeners();
  }

  Future<void> _loadSubscribedTopics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedList = prefs.getStringList(AppConstants.prefSubscribedTopics);
      if (savedList != null) {
        for (var topic in _topics) {
          topic.isSubscribed = savedList.contains(topic.key);
        }
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> toggleTopic(String key) async {
    final index = _topics.indexWhere((t) => t.key == key);
    if (index == -1) return;

    final topic = _topics[index];
    final newState = !topic.isSubscribed;
    topic.isSubscribed = newState;
    notifyListeners();

    if (newState) {
      await _fcmService.subscribeToTopic(key);
      triggerMockNotification(
        '🔔 Canal Activado: ${topic.title}',
        'Ahora recibirás alertas automáticas de esta sección directamente en tu dispositivo.',
      );
    } else {
      await _fcmService.unsubscribeFromTopic(key);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final subscribedKeys = _topics.where((t) => t.isSubscribed).map((t) => t.key).toList();
      await prefs.setStringList(AppConstants.prefSubscribedTopics, subscribedKeys);
    } catch (_) {}
  }

  /// Método para enviar notificación visible tanto en el sistema (barra de notificaciones) como en app
  void triggerMockNotification(String title, String body) {
    // 1. Mostrar notificación nativa en la bandeja del sistema Android
    _fcmService.showNativeSystemNotification(title: title, body: body);

    // 2. Mostrar banner interactivo in-app
    _latestForegroundNotification = RemoteMessage(
      notification: RemoteNotification(
        title: title,
        body: body,
      ),
      sentTime: DateTime.now(),
    );
    _showInAppBanner = true;
    notifyListeners();

    Future.delayed(const Duration(seconds: 6), () {
      dismissBanner();
    });
  }
}
