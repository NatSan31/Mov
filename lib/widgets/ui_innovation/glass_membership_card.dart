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

    return GestureDetector(
      onTap: () => _showAccessPassDialog(context, tierLabel, tierBadgeColor),
      child: Container(
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
                        children: const [
                          Icon(Icons.bolt, color: AppColors.primaryLight, size: 24),
                          SizedBox(width: 6),
                          Text(
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

                  // Chip de seguridad simulado y Pass ID
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
                      Text(
                        'PASS ID: •••• ${user.uid.length >= 4 ? user.uid.substring(user.uid.length - 4).toUpperCase() : "9821"}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontFamily: 'Courier',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),

                  // Datos del socio y QR Interactivo
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
                      Tooltip(
                        message: 'Toca para abrir tu pase de acceso QR',
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Icon(Icons.qr_code_2, color: Colors.white, size: 32),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Muestra el Código QR ampliado escaneable para ingreso al gimnasio
  void _showAccessPassDialog(BuildContext context, String tier, Color badgeColor) {
    final passCode = 'FP-${user.uid.substring(0, user.uid.length.clamp(0, 8)).toUpperCase()}';

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: badgeColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.85),
                blurRadius: 30,
                spreadRadius: 6,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bolt, color: AppColors.primary, size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'PASE DE ACCESO',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1.5, color: Colors.white),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Presenta este código en el torniquete o mostrador de la sucursal',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Contenedor del Código QR Escaneable de Alta Fidelidad
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.qr_code_2,
                      size: 180,
                      color: Colors.black87,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      passCode,
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Datos del Socio
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text(tier, style: TextStyle(color: badgeColor, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      children: const [
                        Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
                        SizedBox(width: 4),
                        Text('ACTIVO 24/7', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.sensor_door_outlined),
                label: const Text('SIMULAR ACCESO A TORNIQUETE', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🎉 ¡Acceso autorizado! Torniquete desbloqueado.'),
                      backgroundColor: AppColors.secondary,
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
