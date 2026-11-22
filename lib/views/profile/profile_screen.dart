import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/services/firebase_service.dart';
import '../../models/order_model.dart';
import '../../widgets/cached_network_image_wrapper.dart';
import '../auth/login_screen.dart';
import '../notifications/notification_topics_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = authProvider.currentUser;
    final isEmailAccount = user?.canEditProfilePhoto ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil de Atleta'),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Cambiar Modo Claro / Oscuro',
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            // Avatar con indicador de proveedor, vista previa en grande y botón de edición
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (user?.photoUrl != null && user!.photoUrl.isNotEmpty) {
                        _showLargePhotoDialog(context, user.photoUrl, user.displayName);
                      }
                    },
                    child: Tooltip(
                      message: 'Toca para previsualizar en grande',
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: user?.subscriptionTier == 'black_vip'
                                ? AppColors.accent
                                : AppColors.primary,
                            width: 3.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: authProvider.isLoading
                            ? const SizedBox(
                                width: 106,
                                height: 106,
                                child: Center(
                                  child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
                                ),
                              )
                            : CachedImageWrapper(
                                imageUrl: user?.photoUrl ?? '',
                                width: 106,
                                height: 106,
                                borderRadius: BorderRadius.circular(53),
                              ),
                      ),
                    ),
                  ),

                  // Botón de cámara / editar foto
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        if (!isEmailAccount) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Restricción de evaluación: Las cuentas vinculadas con Google o GitHub gestionan su foto desde la plataforma original.',
                              ),
                              backgroundColor: AppColors.warning,
                              duration: Duration(seconds: 4),
                            ),
                          );
                        } else {
                          _showPhotoPickerSheet(context, authProvider);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: isEmailAccount ? AppColors.primary : Colors.grey.shade700,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Icon(
                          isEmailAccount ? Icons.camera_alt : Icons.lock,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Nombre y correo
            Text(
              user?.displayName ?? 'Atleta FitPulse',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? '',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 8),

            // Badge de origen de cuenta (Requerimiento de evaluación)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: user?.authProvider == 'google.com'
                    ? Colors.red.withOpacity(0.15)
                    : user?.authProvider == 'github.com'
                        ? Colors.purple.withOpacity(0.15)
                        : AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: user?.authProvider == 'google.com'
                      ? Colors.redAccent
                      : user?.authProvider == 'github.com'
                          ? Colors.purpleAccent
                          : AppColors.primary,
                  width: 1,
                ),
              ),
              child: Text(
                'Proveedor: ${user?.authProvider.toUpperCase() ?? "EMAIL"}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 24),

            // Opciones de Configuración y Estado
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color ?? AppColors.darkCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.notifications_active_outlined, color: AppColors.primaryLight),
                    title: const Text('Canales de Notificaciones Push'),
                    subtitle: const Text('Gestionar suscripciones FCM Topics'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NotificationTopicsScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56, color: Colors.white12),
                  ListTile(
                    leading: const Icon(Icons.palette_outlined, color: AppColors.secondary),
                    title: const Text('Tema de la Aplicación'),
                    subtitle: Text(themeProvider.isDarkMode ? 'Modo Oscuro Activo' : 'Modo Claro Activo'),
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      activeColor: AppColors.primary,
                      onChanged: (_) => themeProvider.toggleTheme(),
                    ),
                  ),
                  const Divider(height: 1, indent: 56, color: Colors.white12),
                  ListTile(
                    leading: const Icon(Icons.verified_user_outlined, color: AppColors.accent),
                    title: const Text('Verificación de Correo'),
                    subtitle: Text(user?.emailVerified == true ? 'Cuenta Verificada en Firebase' : 'Pendiente'),
                    trailing: Icon(
                      user?.emailVerified == true ? Icons.check_circle : Icons.warning,
                      color: user?.emailVerified == true ? AppColors.secondary : AppColors.warning,
                      size: 20,
                    ),
                  ),
                  const Divider(height: 1, indent: 56, color: Colors.white12),
                  ListTile(
                    leading: const Icon(Icons.fitness_center_outlined, color: Colors.blueAccent),
                    title: const Text('Membresía Activa'),
                    subtitle: Text((user?.subscriptionTier ?? 'Smart Basic').toUpperCase()),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Sección de Pedidos y Compras en Firestore
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'MIS PEDIDOS & HISTORIAL (FIRESTORE)',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: Colors.white70,
                ),
              ),
            ),
            const SizedBox(height: 12),

            StreamBuilder<List<OrderModel>>(
              stream: FirebaseService().streamUserOrders(user?.uid ?? ''),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ));
                }

                final orders = snapshot.data ?? [];
                if (orders.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color ?? AppColors.darkCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.receipt_long, color: Colors.grey),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Aún no has realizado pedidos. Compra en la tienda Pro Shop para ver tus comprobantes aquí.',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, idx) {
                    final order = orders[idx];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color ?? AppColors.darkCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.secondary.withOpacity(0.35)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.local_shipping_outlined, color: AppColors.secondary, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pedido #${order.id.substring(0, order.id.length.clamp(0, 8)).toUpperCase()}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${order.items.length} artículos • ${order.paymentCardBrand} •••• ${order.paymentLast4}',
                                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        order.status,
                                        style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '\$${order.total.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 28),

            // Botón Cerrar Sesión
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.logout, size: 20),
              label: const Text('CERRAR SESIÓN', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () async {
                await authProvider.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Muestra la imagen en grande con diálogo modal
  void _showLargePhotoDialog(BuildContext context, String imageUrl, String name) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.primary, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.8),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Column(
                  children: [
                    CachedImageWrapper(
                      imageUrl: imageUrl,
                      width: 280,
                      height: 280,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white70),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPhotoPickerSheet(BuildContext context, AuthProvider authProvider) {
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Actualizar Foto de Perfil (Firebase Storage)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                const Text(
                  'La imagen se guardará en la nube de Firebase y se sincronizará en todo tu panel.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.photo_camera, color: AppColors.primary),
                  title: const Text('Tomar Foto con la Cámara'),
                  subtitle: const Text('Captura tu foto con la cámara del teléfono'),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    try {
                      final XFile? photo = await picker.pickImage(
                        source: ImageSource.camera,
                        maxWidth: 800,
                        maxHeight: 800,
                        imageQuality: 85,
                      );
                      if (photo != null) {
                        final file = File(photo.path);
                        final success = await authProvider.updateProfilePhoto(file);
                        if (context.mounted && success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Foto subida exitosamente a Firebase Storage y sincronizada'),
                              backgroundColor: AppColors.secondary,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al subir foto: $e'), backgroundColor: AppColors.error),
                        );
                      }
                    }
                  },
                ),
                const Divider(color: Colors.white12),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: AppColors.secondary),
                  title: const Text('Elegir de la Galería'),
                  subtitle: const Text('Selecciona una imagen guardada en tu dispositivo'),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    try {
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 800,
                        maxHeight: 800,
                        imageQuality: 85,
                      );
                      if (image != null) {
                        final file = File(image.path);
                        final success = await authProvider.updateProfilePhoto(file);
                        if (context.mounted && success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Foto subida exitosamente a Firebase Storage y sincronizada'),
                              backgroundColor: AppColors.secondary,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al subir foto: $e'), backgroundColor: AppColors.error),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
