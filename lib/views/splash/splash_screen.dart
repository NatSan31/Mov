import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../../core/constants/app_colors.dart';
import '../../core/services/firebase_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/onboarding_provider.dart';
import '../onboarding/onboarding_screen.dart';
import '../auth/login_screen.dart';
import '../auth/email_verification_screen.dart';
import '../dashboard/main_navigation_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final onboardingProvider = context.read<OnboardingProvider>();
        await onboardingProvider.checkOnboardingStatus();

        // Breve pausa para apreciación de branding
        await Future.delayed(const Duration(milliseconds: 1400));

        if (!context.mounted) return;

        // 1. Si no ha visto el onboarding por primera vez
        if (!onboardingProvider.isCompleted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          );
          return;
        }

        // 2. Persistencia de Sesión Real (Auto-Login / Recordarme de Firebase)
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          try {
            await currentUser.reload();
          } catch (_) {}

          final isSocial = currentUser.providerData.any((p) => p.providerId != 'password');
          final isVerified = currentUser.emailVerified || isSocial;

          if (isVerified) {
            // Sincronizar perfil en el Provider
            final authProvider = context.read<AuthProvider>();
            final profile = await FirebaseService().getUserProfile(currentUser.uid);
            if (profile != null) {
              authProvider.clearMessages();
            }

            if (context.mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
              );
              return;
            }
          } else {
            if (context.mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const EmailVerificationScreen()),
              );
              return;
            }
          }
        }

        // 3. Si no hay sesión activa, ir al login
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      } catch (e) {
        debugPrint('[SplashScreen] Navegación de contingencia: $e');
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(Icons.bolt, size: 72, color: AppColors.primary),
            ),
            const SizedBox(height: 28),
            const Text(
              'FITPULSE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'CLUB & PRO SHOP',
              style: TextStyle(
                color: AppColors.secondary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
