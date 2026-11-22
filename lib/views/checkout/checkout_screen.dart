import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/credit_card_validator.dart';
import '../../core/services/biometric_service.dart';
import '../../providers/cart_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatelessWidget {
  final bool isSubscription;

  const CheckoutScreen({super.key, required this.isSubscription});

  @override
  Widget build(BuildContext context) {
    final cardNumberController = TextEditingController();
    final cardHolderController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final cart = context.watch<CartProvider>();
    final subscription = context.watch<SubscriptionProvider>();
    final auth = context.watch<AuthProvider>();

    final double totalAmount = isSubscription
        ? subscription.currentPlanPrice
        : cart.total;

    final String checkoutTitle = isSubscription
        ? 'Suscripción: ${subscription.selectedPlan.name}'
        : 'Pago Seguro de Pedido';

    return Scaffold(
      appBar: AppBar(
        title: Text(checkoutTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Badge de seguridad SSL / Stripe PCI DSS
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.security, color: AppColors.secondary, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Pasarela Encriptada de 256-bits. Certificado PCI-DSS Compliant.',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Resumen del Monto a Pagar
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color ?? AppColors.darkCard,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TOTAL A CARGAR', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            isSubscription ? 'Membresía ${subscription.billingCycle == BillingCycle.monthly ? "Mensual" : "Anual"}' : 'Pedido Pro Shop (${cart.totalItemsCount} artículos)',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '\$${totalAmount.toStringAsFixed(2)} USD',
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'DATOS DE LA TARJETA',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.white70),
              ),
              const SizedBox(height: 12),

              // Número de tarjeta con algoritmo de Luhn
              CustomTextField(
                controller: cardNumberController,
                label: 'Número de Tarjeta',
                hint: '4000 1234 5678 9010',
                prefixIcon: Icons.credit_card,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(19),
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    final text = CreditCardValidator.formatCardNumber(newValue.text);
                    return TextEditingValue(
                      text: text,
                      selection: TextSelection.collapsed(offset: text.length),
                    );
                  }),
                ],
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Ingresa el número de tarjeta';
                  if (!CreditCardValidator.isValidLuhn(val)) return 'Número de tarjeta inválido (Luhn)';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Nombre del titular
              CustomTextField(
                controller: cardHolderController,
                label: 'Nombre del Titular',
                hint: 'EMILIO ATLETA',
                prefixIcon: Icons.person_outline,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Ingresa el nombre como figura en la tarjeta';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Fecha de expiración y CVV
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: expiryController,
                      label: 'Vencimiento (MM/YY)',
                      hint: '12/28',
                      prefixIcon: Icons.date_range,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          var text = newValue.text;
                          if (text.length > 2) {
                            text = '${text.substring(0, 2)}/${text.substring(2)}';
                          }
                          return TextEditingValue(
                            text: text,
                            selection: TextSelection.collapsed(offset: text.length),
                          );
                        }),
                      ],
                      validator: (val) {
                        if (val == null || !CreditCardValidator.isValidExpiryDate(val)) {
                          return 'Fecha inválida';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: CustomTextField(
                      controller: cvvController,
                      label: 'Código CVV',
                      hint: '123',
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validator: (val) {
                        if (val == null || val.length < 3) return 'CVV de 3 o 4 dígitos';
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Botón de Pago con Confirmación Biométrica
              CustomButton(
                text: 'PAGAR \$${totalAmount.toStringAsFixed(2)} USD',
                icon: Icons.fingerprint,
                isLoading: isSubscription ? subscription.isProcessingSubscription : cart.isProcessingPayment,
                onPressed: () async {
                  if (formKey.currentState?.validate() ?? false) {
                    // Integración con sensor nativo biométrico para confirmar transacción
                    final authenticated = await BiometricService().authenticate(
                      localizedReason: 'Autoriza el cargo de \$${totalAmount.toStringAsFixed(2)} USD en FitPulse',
                    );

                    if (!authenticated) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Autenticación biométrica requerida para procesar el pago.'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                      return;
                    }

                    if (!context.mounted) return;

                    final cardType = CreditCardValidator.detectCardType(cardNumberController.text);
                    final brandName = cardType.name.toUpperCase();
                    final cleanDigits = cardNumberController.text.replaceAll(' ', '');
                    final last4 = cleanDigits.length >= 4 ? cleanDigits.substring(cleanDigits.length - 4) : '4242';

                    if (isSubscription) {
                      final success = await subscription.subscribe(
                        authProvider: auth,
                        cardLast4: last4,
                        cardBrand: brandName,
                      );
                      if (success && context.mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => OrderSuccessScreen(
                              orderId: 'SUB-${DateTime.now().millisecondsSinceEpoch}',
                              amount: totalAmount,
                              isSubscription: true,
                              subscriptionPlanName: subscription.selectedPlan.name,
                            ),
                          ),
                        );
                      }
                    } else {
                      final order = await cart.processOrder(
                        userId: auth.currentUser?.uid ?? 'guest_user',
                        cardLast4: last4,
                        cardBrand: brandName,
                      );
                      if (order != null && context.mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => OrderSuccessScreen(
                              orderId: order.id,
                              amount: order.total,
                              isSubscription: false,
                            ),
                          ),
                        );
                      }
                    }
                  }
                },
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'El pago se procesará inmediatamente y se generará tu recibo fiscal.',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
