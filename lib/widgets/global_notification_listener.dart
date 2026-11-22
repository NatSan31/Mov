import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../providers/sensor_provider.dart';
import '../core/constants/app_colors.dart';
import 'shake_reward_dialog.dart';

class GlobalAppOverlayListener extends StatelessWidget {
  final Widget child;

  const GlobalAppOverlayListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,

        // 1. Escuchador Global de Notificaciones Push (FCM Foreground Listener)
        Consumer<NotificationProvider>(
          builder: (context, notifProvider, _) {
            if (!notifProvider.showInAppBanner || notifProvider.latestForegroundNotification == null) {
              return const SizedBox.shrink();
            }

            final notif = notifProvider.latestForegroundNotification!.notification;
            final title = notif?.title ?? 'Notificación FitPulse';
            final body = notif?.body ?? 'Tienes una nueva actualización en tu cuenta.';

            return Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              right: 16,
              child: Material(
                color: Colors.transparent,
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 350),
                  tween: Tween(begin: -50.0, end: 0.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, value),
                      child: child,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F1F1F),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_active, color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                body,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white60, size: 18),
                          onPressed: () => notifProvider.dismissBanner(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // 2. Escuchador Global de Sensor Acelerómetro (Shake-to-Win)
        Consumer<SensorProvider>(
          builder: (context, sensorProvider, _) {
            if (!sensorProvider.shakeRewardAvailable) {
              return const SizedBox.shrink();
            }

            return ShakeRewardDialog(
              couponCode: sensorProvider.unlockedCouponCode ?? 'FITPULSE15',
              onDismiss: () => sensorProvider.dismissShakeReward(),
            );
          },
        ),
      ],
    );
  }
}
