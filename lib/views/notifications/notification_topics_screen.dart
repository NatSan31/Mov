import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/notification_provider.dart';

class NotificationTopicsScreen extends StatelessWidget {
  const NotificationTopicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifProvider = context.watch<NotificationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Canales de Notificaciones'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Temas de Interés (FCM Topics)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text(
              'Suscríbete a los canales que deseas recibir en primer plano, segundo plano o con la app cerrada.',
              style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 24),

            // Lista de Temas FCM
            ...notifProvider.topics.map((topic) {
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color ?? AppColors.darkCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: topic.isSubscribed ? AppColors.primary.withOpacity(0.4) : Colors.white10,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: topic.isSubscribed ? AppColors.primary.withOpacity(0.15) : Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        topic.isSubscribed ? Icons.notifications_active : Icons.notifications_none,
                        color: topic.isSubscribed ? AppColors.primary : Colors.grey,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topic.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            topic.description,
                            style: const TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: topic.isSubscribed,
                      activeColor: AppColors.primary,
                      onChanged: (_) => notifProvider.toggleTopic(topic.key),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 30),

            // Tarjeta explicativa de los 3 estados del ciclo de vida
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF1B263B),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF415A77)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'COMPATIBILIDAD CON CICLO DE VIDA (FCM)',
                    style: TextStyle(
                      color: Color(0xFFE0E1DD),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 10),
                  _LifeCycleRow(state: 'Primer Plano (Foreground)', desc: 'Listener global in-app activo en todas las pantallas.'),
                  SizedBox(height: 6),
                  _LifeCycleRow(state: 'Segundo Plano (Background)', desc: 'Manejador de alto nivel onBackgroundMessage registrado.'),
                  SizedBox(height: 6),
                  _LifeCycleRow(state: 'Cerrada (Terminated)', desc: 'Recepción y apertura mediante getInitialMessage().'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LifeCycleRow extends StatelessWidget {
  final String state;
  final String desc;

  const _LifeCycleRow({required this.state, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle, color: AppColors.secondary, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 12, color: Colors.white70),
              children: [
                TextSpan(text: '$state: ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                TextSpan(text: desc),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
