import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../dashboard/main_navigation_screen.dart';
import '../../widgets/custom_button.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderId;
  final double amount;
  final bool isSubscription;
  final String? subscriptionPlanName;

  const OrderSuccessScreen({
    super.key,
    required this.orderId,
    required this.amount,
    this.isSubscription = false,
    this.subscriptionPlanName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.secondary, width: 2),
                ),
                child: const Icon(Icons.check, size: 54, color: AppColors.secondary),
              ),
              const SizedBox(height: 24),
              Text(
                isSubscription ? '¡Membresía Activada!' : '¡Pago Procesado con Éxito!',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                isSubscription
                    ? 'Tu suscripción a $subscriptionPlanName ya está activa en tu cuenta y carnet digital.'
                    : 'Hemos recibido tu pedido en Pro Shop. En breve recibirás la notificación de despacho.',
                style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Detalle de la Transacción
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color ?? AppColors.darkCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Folio Transacción', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text(
                          orderId.substring(0, orderId.length.clamp(0, 16)),
                          style: const TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                    const Divider(height: 16, color: Colors.white12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Monto Cobrado', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text(
                          '\$${amount.toStringAsFixed(2)} USD',
                          style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    const Divider(height: 16, color: Colors.white12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Método de Pago', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text('Tarjeta Encriptada (Stripe)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              CustomButton(
                text: 'VOLVER AL INICIO',
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                    (route) => false,
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
