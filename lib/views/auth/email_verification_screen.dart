import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../dashboard/main_navigation_screen.dart';
import 'login_screen.dart';
import '../../widgets/custom_button.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificación de Correo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: const Icon(
                      Icons.mark_email_unread_outlined,
                      size: 50,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Confirma tu Correo Electrónico',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Hemos enviado un enlace de confirmación a:\n${auth.currentUser?.email ?? "tu correo"}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Por requerimientos de seguridad, debes validar tu cuenta antes de acceder a la plataforma.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  // Mensaje de éxito si reenvió
                  if (auth.successMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.success),
                      ),
                      child: Text(
                        auth.successMessage!,
                        style: const TextStyle(color: AppColors.success, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Botón Comprobar Verificación
                  CustomButton(
                    text: 'YA HE CONFIRMADO MI CORREO',
                    isLoading: auth.isLoading,
                    onPressed: () async {
                      final isVerified = await auth.checkEmailVerified();
                      if (isVerified && context.mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                        );
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Aún no detectamos la verificación. Haz clic en el enlace de tu correo.'),
                            backgroundColor: AppColors.warning,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 14),

                  // Reenviar correo de confirmación
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white30),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.send, size: 18),
                    label: const Text('Reenviar Correo de Confirmación'),
                    onPressed: auth.isLoading
                        ? null
                        : () async {
                            await auth.resendEmailVerification();
                          },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
