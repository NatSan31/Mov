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
        title: const Text('Notificaciones y Alertas'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Canales de Avisos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text(
              'Personaliza qué novedades, recordatorios y ofertas deseas recibir directamente en tu teléfono.',
              style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 20),

            // Lista de Canales de Alertas
            ...notifProvider.topics.map((topic) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
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

            const SizedBox(height: 24),

            // Sección de Pruebas de Notificaciones en Vivo
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color ?? AppColors.darkCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send_to_mobile, color: AppColors.secondary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Probar Alertas en tu Teléfono',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              'Envía una notificación instantánea a tu barra de estado',
                              style: TextStyle(color: Colors.grey, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 8),

                  _buildTestNotificationTile(
                    context: context,
                    icon: Icons.local_offer_outlined,
                    color: Colors.amber,
                    title: 'Promoción Pro Shop',
                    subtitle: '¡Flash Sale 20% OFF en Proteína Whey!',
                    onTap: () {
                      notifProvider.triggerMockNotification(
                        '⚡ ¡Flash Sale en FitPulse Pro Shop!',
                        'Aprovecha 20% de descuento en suplementos de proteína pura.',
                      );
                      _showSentToast(context);
                    },
                  ),
                  _buildTestNotificationTile(
                    context: context,
                    icon: Icons.fitness_center,
                    color: AppColors.primary,
                    title: 'Recordatorio de Entrenamiento',
                    subtitle: '¡Es momento de tu rutina del día!',
                    onTap: () {
                      notifProvider.triggerMockNotification(
                        '🏋️ ¡Hora de entrenar en FitPulse!',
                        'Tu rutina de fuerza te espera hoy. ¡No rompas tu racha!',
                      );
                      _showSentToast(context);
                    },
                  ),
                  _buildTestNotificationTile(
                    context: context,
                    icon: Icons.qr_code_scanner,
                    color: Colors.greenAccent,
                    title: 'Acceso a Instalaciones',
                    subtitle: 'Tu torniquete de acceso está listo.',
                    onTap: () {
                      notifProvider.triggerMockNotification(
                        '🎟️ Pase de Entrada Confirmado',
                        'Torniquete de Sede Central listo para tu acceso biométrico.',
                      );
                      _showSentToast(context);
                    },
                  ),
                  _buildTestNotificationTile(
                    context: context,
                    icon: Icons.emoji_events_outlined,
                    color: Colors.purpleAccent,
                    title: 'Reto Fitness Semanal',
                    subtitle: 'Nuevo desafío de 10,000 pasos completado.',
                    onTap: () {
                      notifProvider.triggerMockNotification(
                        '🏆 ¡Meta Alcanzada!',
                        'Has superado los 10,000 pasos de hoy. Pasa a recepción por tu premio.',
                      );
                      _showSentToast(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestNotificationTile({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(0, 32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: onTap,
                child: const Text('ENVIAR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSentToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📲 Alerta enviada a tu dispositivo'),
        backgroundColor: AppColors.secondary,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
