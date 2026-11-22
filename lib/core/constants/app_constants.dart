class AppConstants {
  static const String appName = 'FitPulse';
  static const String appTagline = 'Tu Club de Fitness y Alto Rendimiento';

  // FCM Topics para suscripción de usuarios
  static const String topicPromociones = 'promociones';
  static const String topicNovedades = 'novedades';
  static const String topicEventos = 'eventos_fitness';
  static const String topicConsejosSalud = 'consejos_salud';

  // Colecciones de Firestore
  static const String colUsers = 'users';
  static const String colProducts = 'products';
  static const String colSubscriptions = 'subscriptions';
  static const String colOrders = 'orders';
  static const String colLocations = 'gym_locations';
  static const String colNotifications = 'notifications';

  // Shared Preferences Keys
  static const String prefThemeMode = 'fitpulse_theme_mode';
  static const String prefOnboardingCompleted = 'fitpulse_onboarding_done';
  static const String prefSubscribedTopics = 'fitpulse_subscribed_topics';
}
