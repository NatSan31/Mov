import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sensor_provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/cached_network_image_wrapper.dart';
import '../../widgets/ui_innovation/fitness_pulse_radar.dart';
import '../../widgets/ui_innovation/glass_membership_card.dart';
import '../notifications/notification_topics_screen.dart';
import '../admin/add_product_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final productsProvider = context.watch<ProductsProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onLongPress: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddProductScreen()),
            );
          },
          child: Row(
            children: [
              // Sincronización dinámica de la foto de perfil sin parpadeos
              CachedImageWrapper(
                imageUrl: user?.photoUrl ?? '',
                width: 38,
                height: 38,
                borderRadius: BorderRadius.circular(19),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'HOLA DE NUEVO',
                    style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1),
                  ),
                  Text(
                    user?.displayName ?? 'Atleta FitPulse',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          // Botón de Canales / Notificaciones FCM
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Canales y Notificaciones',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationTopicsScreen()),
              );
            },
          ),
          // Botón para enviar alerta de prueba inmediata
          IconButton(
            icon: const Icon(Icons.send_to_mobile, color: AppColors.secondary),
            tooltip: 'Enviar Alerta de Prueba',
            onPressed: () {
              context.read<NotificationProvider>().triggerMockNotification(
                    '¡Flash Sale en FitPulse Pro Shop!',
                    'Agita tu teléfono con el acelerómetro para desbloquear 15% OFF en Whey Isolate.',
                  );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          productsProvider.loadProducts();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Tarjeta Glassmorphic de Membresía del Usuario (Con QR de acceso interactivo)
              if (user != null)
                GlassMembershipCard(user: user)
              else
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(child: Text('Cargando información del atleta...')),
                ),

              const SizedBox(height: 20),

              // 2. Widget de Telemetría Biometría Aislado con Consumer (Sin afectar al AppBar ni fotos)
              Consumer<SensorProvider>(
                builder: (context, sensor, _) {
                  return FitnessPulseRadar(
                    intensity: sensor.motionIntensity,
                    steps: sensor.stepsSimulated,
                  );
                },
              ),

              const SizedBox(height: 24),

              // 3. Banner Informativo de Sensor Shake
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.15),
                      AppColors.secondary.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.screen_rotation, color: AppColors.secondary, size: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '¡Agita tu dispositivo para ganar!',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'El acelerómetro detectará el movimiento y desbloqueará un cupón exclusivo.',
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<SensorProvider>().triggerShakeReward();
                      },
                      child: const Text('PROBAR', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 4. Catálogo Rápido de Suplementos Destacados
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'DESTACADOS DE PRO SHOP',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: Colors.white70,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<NavigationProvider>().setIndex(1);
                    },
                    child: const Text('Ver Todo', style: TextStyle(color: AppColors.primaryLight)),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: productsProvider.products.take(4).length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final product = productsProvider.products[index];
                    return Container(
                      width: 160,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color ?? AppColors.darkCard,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CachedImageWrapper(
                              imageUrl: product.imageUrl,
                              width: double.infinity,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '\$${product.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: AppColors.secondary,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Icon(Icons.star, color: AppColors.accent, size: 14),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
