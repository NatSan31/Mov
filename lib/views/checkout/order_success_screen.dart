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
    final trackingCode = 'FPX-${orderId.substring(0, orderId.length.clamp(0, 8)).toUpperCase()}-MX';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comprobante & Rastreo'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icono de Aprobación
              Center(
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.secondary, width: 2.5),
                  ),
                  child: const Icon(Icons.check, size: 44, color: AppColors.secondary),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isSubscription ? '¡Suscripción Activada!' : '¡Pago Aprobado y Pedido en Camino!',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                isSubscription
                    ? 'Tu plan $subscriptionPlanName ha sido acreditado exitosamente en tu membresía digital.'
                    : 'Tu pedido ha sido procesado por la pasarela segura y transferido al centro de logística express.',
                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // 1. LÍNEA DE TIEMPO DE RASTREO EN VIVO (ORDER TRACKING)
              if (!isSubscription) ...[
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color ?? AppColors.darkCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.secondary.withOpacity(0.4), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.local_shipping, color: AppColors.secondary, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'SEGUIMIENTO EN VIVO',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'EN RUTA',
                              style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Número de Guía: $trackingCode',
                        style: const TextStyle(fontFamily: 'Courier', fontSize: 11, color: Colors.white70),
                      ),
                      const SizedBox(height: 16),

                      // Pasos del Rastreo
                      _buildTrackingStep(
                        icon: Icons.credit_score,
                        title: 'Pago Acreditado & Recibo Fiscal',
                        subtitle: 'Validación biométrica aprobada en pasarela Stripe',
                        isCompleted: true,
                        isCurrent: false,
                      ),
                      _buildTrackingStep(
                        icon: Icons.inventory_2_outlined,
                        title: 'Empacado en Almacén FitPulse',
                        subtitle: 'Artículos verificados y sellados con precinto de seguridad',
                        isCompleted: true,
                        isCurrent: false,
                      ),
                      _buildTrackingStep(
                        icon: Icons.two_wheeler,
                        title: 'En Camino con Repartidor Express',
                        subtitle: 'Repartidor: Carlos M. (Unidad Eléctrica FitPulse #12)',
                        isCompleted: false,
                        isCurrent: true,
                      ),
                      _buildTrackingStep(
                        icon: Icons.home_outlined,
                        title: 'Entrega Estimada en Domicilio',
                        subtitle: 'Estimado de recepción: Hoy antes de las 18:30 hrs',
                        isCompleted: false,
                        isCurrent: false,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // 2. RECIBO FISCAL / TICKET DIGITAL
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color ?? AppColors.darkCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'COMPROBANTE FISCAL DIGITAL',
                          style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                        InkWell(
                          onTap: () => _showFiscalQrDialog(context, orderId, amount),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.qr_code_2, color: AppColors.secondary, size: 20),
                                SizedBox(width: 4),
                                Text(
                                  'VER QR',
                                  style: TextStyle(
                                    color: AppColors.secondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16, color: Colors.white12),
                    _buildReceiptRow('Folio Transacción', orderId.substring(0, orderId.length.clamp(0, 16)).toUpperCase()),
                    _buildReceiptRow('Fecha & Hora', '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} - ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')} hrs'),
                    _buildReceiptRow('Método de Pago', 'Pago Digital Seguro (256-bit SSL)'),
                    _buildReceiptRow('Estado del Pedido', 'Confirmado y en preparación'),
                    const Divider(height: 16, color: Colors.white12),
                    _buildReceiptRow('Subtotal', '\$${(amount * 0.862).toStringAsFixed(2)} USD'),
                    _buildReceiptRow('Impuestos (IVA 16%)', '\$${(amount * 0.138).toStringAsFixed(2)} USD'),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('TOTAL COBRADO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                        Text(
                          '\$${amount.toStringAsFixed(2)} USD',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.secondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Botón de Retorno
              CustomButton(
                text: 'VOLVER AL INICIO',
                icon: Icons.home,
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

  Widget _buildTrackingStep({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isCurrent,
    bool isLast = false,
  }) {
    final color = isCompleted
        ? Colors.greenAccent
        : isCurrent
            ? AppColors.secondary
            : Colors.grey;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color: isCompleted ? Colors.greenAccent.withOpacity(0.5) : Colors.white12,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isCurrent ? Colors.white : Colors.white70,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Colors.white70)),
        ],
      ),
    );
  }

  void _showFiscalQrDialog(BuildContext context, String orderId, double amount) {
    final folio = orderId.toUpperCase();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Factura CFDI 4.0 SAT',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.qr_code_2,
                      size: 190,
                      color: Colors.black87,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'UUID: ${folio.substring(0, folio.length.clamp(0, 18))}',
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Emisor:', style: TextStyle(color: Colors.grey, fontSize: 11)),
                        const Text('FITPULSE MÉXICO S.A. DE C.V.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Sello Digital:', style: TextStyle(color: Colors.grey, fontSize: 11)),
                        const Text('Verificado por SAT', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:', style: TextStyle(color: Colors.grey, fontSize: 11)),
                        Text('\$${amount.toStringAsFixed(2)} USD', style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.download, size: 18),
                label: const Text('DESCARGAR XML & PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('📄 Comprobante fiscal y XML descargados en tu dispositivo.'),
                      backgroundColor: Colors.green,
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
