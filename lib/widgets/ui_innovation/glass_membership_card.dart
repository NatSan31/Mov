import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';

class GlassMembershipCard extends StatelessWidget {
  final UserModel user;

  const GlassMembershipCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final isVip = user.subscriptionTier == 'black_vip';
    final isPro = user.subscriptionTier == 'pro';

    final gradientColors = isVip
        ? [const Color(0xFF1E1E1E), const Color(0xFF0A0A0A), const Color(0xFF333333)]
        : isPro
            ? [const Color(0xFFB71C1C), const Color(0xFF560000), const Color(0xFF2B0000)]
            : [const Color(0xFF263238), const Color(0xFF37474F), const Color(0xFF102027)];

    final tierLabel = isVip
        ? 'BLACK ELITE VIP'
        : isPro
            ? 'PRO PERFORMANCE'
            : 'SMART BASIC';

    final tierBadgeColor = isVip
        ? AppColors.accent
        : isPro
            ? AppColors.primaryLight
            : Colors.lightBlueAccent;

    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isVip ? AppColors.accent.withOpacity(0.6) : Colors.white.withOpacity(0.18),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isVip
                ? AppColors.accent.withOpacity(0.25)
                : Colors.black.withOpacity(0.4),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Patrón de marcas de agua abstractas
          Positioned(
            right: -20,
            bottom: -30,
            child: Icon(
              Icons.fitness_center,
              size: 160,
              color: Colors.white.withOpacity(0.05),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.bolt, color: AppColors.primaryLight, size: 24),
                        const SizedBox(width: 6),
                        const Text(
                          'FITPULSE CLUB',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: tierBadgeColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: tierBadgeColor, width: 1),
                      ),
                      child: Text(
                        tierLabel,
                        style: TextStyle(
                          color: tierBadgeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),

                // Chip de seguridad simulado
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 26,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF8C6D15)),
                      ),
                      child: const Center(
                        child: Icon(Icons.wifi, size: 16, color: Colors.black54),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'PASS ID: •••• 9821',
                      style: TextStyle(
                        color: Colors.white54,
                        fontFamily: 'Courier',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),

                // Datos del socio
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MIEMBRO TITULAR',
                          style: TextStyle(color: Colors.white54, fontSize: 9, letterSpacing: 1),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.displayName.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const Row(
                      children: [
                        Icon(Icons.qr_code_2, color: Colors.white70, size: 36),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
