import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/auth_provider.dart';
import '../checkout/checkout_screen.dart';

class SubscriptionPlansScreen extends StatelessWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subProvider = context.watch<SubscriptionProvider>();
    final authProvider = context.watch<AuthProvider>();
    final currentTier = authProvider.currentUser?.subscriptionTier ?? 'none';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Membresías del Club'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            const Text(
              'Eleva tu Potencial al Siguiente Nivel',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Elige el plan ideal para tus objetivos. Cambia o cancela cuando quieras.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Selector de Facturación: Mensual / Anual
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color ?? AppColors.darkCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => subProvider.setBillingCycle(BillingCycle.monthly),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: subProvider.billingCycle == BillingCycle.monthly ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'MENSUAL',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: subProvider.billingCycle == BillingCycle.monthly ? Colors.white : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => subProvider.setBillingCycle(BillingCycle.yearly),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: subProvider.billingCycle == BillingCycle.yearly ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'ANUAL',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: subProvider.billingCycle == BillingCycle.yearly ? Colors.white : Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '-20%',
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Lista de Planes con Diseño Responsivo sin Overflows
            ...subProvider.plans.map((plan) {
              final isUserCurrentTier = currentTier == plan.id;
              final price = subProvider.billingCycle == BillingCycle.monthly
                  ? plan.priceMonthly
                  : (plan.priceYearly / 12.0);

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color ?? AppColors.darkCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isUserCurrentTier
                        ? AppColors.secondary
                        : plan.isPopular
                            ? AppColors.primary
                            : Colors.white10,
                    width: plan.isPopular || isUserCurrentTier ? 2 : 1,
                  ),
                  boxShadow: [
                    if (plan.isPopular)
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                  ],
                ),
                child: Column(
                  children: [
                    if (plan.isPopular)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                        ),
                        child: const Text(
                          'MÁS POPULAR ENTRE ATLETAS',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  plan.name,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                                ),
                              ),
                              if (isUserCurrentTier)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'PLAN ACTUAL',
                                    style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 10),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(plan.tagline, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 16),

                          // Precio Adaptativo Responsivo con Wrap (Sin Overflow)
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Text(
                                '\$${price.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white),
                              ),
                              const Text(' / mes', style: TextStyle(color: Colors.grey, fontSize: 13)),
                              if (subProvider.billingCycle == BillingCycle.yearly)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    'Facturado \$${plan.priceYearly.toStringAsFixed(2)}/año',
                                    style: const TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          const Divider(color: Colors.white12),
                          const SizedBox(height: 12),
                          ...plan.benefits.map((benefit) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: AppColors.secondary, size: 18),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(benefit, style: const TextStyle(fontSize: 13, color: Colors.white70)),
                                    ),
                                  ],
                                ),
                              )),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: plan.isPopular ? AppColors.primary : AppColors.darkBackground,
                              foregroundColor: Colors.white,
                              side: plan.isPopular ? null : const BorderSide(color: Colors.white24),
                              minimumSize: const Size(double.infinity, 48),
                            ),
                            onPressed: () {
                              subProvider.selectPlan(plan);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const CheckoutScreen(isSubscription: true),
                                ),
                              );
                            },
                            child: Text(
                              isUserCurrentTier ? 'RENOVAR O CAMBIAR MODALIDAD' : 'SUSCRIBIRME AHORA',
                              style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
