import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
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
            // Avatar con indicador de proveedor y botón de edición restringido
            Center(
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: user?.subscriptionTier == 'black_vip'
                            ? AppColors.accent
                            : AppColors.primary,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CachedImageWrapper(
                      imageUrl: user?.photoUrl ?? '',
                      width: 104,
                      height: 104,
                      borderRadius: BorderRadius.circular(52),
                    ),
                  ),

                  // Botón de cámara / editar foto
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        if (!isEmailAccount) {
                          // Regla de Requerimientos: Restricción de edición estricta
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Restricción: Las cuentas vinculadas con proveedores externos (Google/GitHub) gestionan su foto desde la plataforma original.',
                              ),
                              backgroundColor: AppColors.warning,
                              duration: Duration(seconds: 4),
                            ),
                          );
                        } else {
                          // Permitido para email/password: Diálogo de selección o actualización
                          _showEditPhotoDialog(context, authProvider);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isEmailAccount ? AppColors.primary : Colors.grey,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
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

            const SizedBox(height: 16),

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

            const SizedBox(height: 12),

            // Badge de Proveedor de Autenticación
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    user?.authProvider == 'google.com'
                        ? Icons.g_mobiledata
                        : user?.authProvider == 'github.com'
                            ? Icons.code
                            : Icons.email_outlined,
                    size: 16,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Autenticado vía ${user?.authProvider.toUpperCase() ?? "EMAIL"}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Mensajes de estado
            if (authProvider.errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error),
                ),
                child: Text(authProvider.errorMessage!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
              ),

            if (authProvider.successMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success),
                ),
                child: Text(authProvider.successMessage!, style: const TextStyle(color: AppColors.success, fontSize: 12)),
              ),

            // Opciones y Preferencias de la Cuenta
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color ?? AppColors.darkCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.notifications_active_outlined, color: AppColors.primary),
                    title: const Text('Temas de Notificaciones (FCM)'),
                    subtitle: const Text('Configura tus canales suscritos'),
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
                    subtitle: Text(user?.emailVerified == true ? 'Cuenta Verificada' : 'Pendiente'),
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
                    subtitle: Text((user?.subscriptionTier ?? 'none').toUpperCase()),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
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

  void _showEditPhotoDialog(BuildContext context, AuthProvider authProvider) {
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
                const SizedBox(height: 8),
                const Text(
                  'El nuevo avatar se sincronizará dinámicamente en el dashboard y en la nube.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: AppColors.primary),
                  title: const Text('Subir Nueva Foto a Storage'),
                  subtitle: const Text('Simula o carga archivo JPEG'),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    // Subida simulada con archivo dummy
                    final dummyFile = File('/tmp/fitpulse_avatar.jpg');
                    await authProvider.updateProfilePhoto(dummyFile);
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
