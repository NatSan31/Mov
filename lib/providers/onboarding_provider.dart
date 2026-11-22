import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

class OnboardingItem {
  final String title;
  final String subtitle;
  final String icon;

  const OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class OnboardingProvider extends ChangeNotifier {
  final PageController pageController = PageController();
  int _currentPage = 0;
  int get currentPage => _currentPage;

  bool _isCompleted = false;
  bool get isCompleted => _isCompleted;

  final List<OnboardingItem> pages = const [
    OnboardingItem(
      title: 'Bienvenido a FitPulse Club',
      subtitle: 'La plataforma definitiva de entrenamiento inteligente, nutrición y rendimiento físico.',
      icon: 'fitness_center',
    ),
    OnboardingItem(
      title: 'Pro Shop & Membresías VIP',
      subtitle: 'Accede a suplementación de élite y suscríbete a nuestros planes exclusivos con un solo toque.',
      icon: 'card_membership',
    ),
    OnboardingItem(
      title: 'Hardware & Geolocalización',
      subtitle: 'Monitorea tu actividad con acelerómetro nativo, entra con biometría y localiza tu sede más cercana.',
      icon: 'explore',
    ),
  ];

  void setPage(int index) {
    if (_currentPage != index) {
      _currentPage = index;
      notifyListeners();
    }
  }

  void nextPage() {
    if (_currentPage < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> completeOnboarding() async {
    _isCompleted = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.prefOnboardingCompleted, true);
    } catch (_) {}
  }

  Future<void> checkOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isCompleted = prefs.getBool(AppConstants.prefOnboardingCompleted) ?? false;
      notifyListeners();
    } catch (_) {}
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
