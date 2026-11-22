import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../core/services/biometric_service.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'email_verification_screen.dart';
import '../dashboard/main_navigation_screen.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo y Cabecera
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: const Icon(Icons.bolt, size: 48, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '¡Bienvenido de vuelta!',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Inicia sesión en tu cuenta de FitPulse Club',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Mensaje de Error si existe
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      if (auth.errorMessage != null) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.error),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  auth.errorMessage!,
                                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // Campos de formulario
                  CustomTextField(
                    controller: emailController,
                    label: 'Correo Electrónico',
                    hint: 'ejemplo@fitpulse.club',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Ingresa tu correo';
                      if (!val.contains('@')) return 'Ingresa un correo válido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  CustomTextField(
                    controller: passwordController,
                    label: 'Contraseña',
                    hint: '••••••••',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Ingresa tu contraseña';
                      if (val.length < 6) return 'Mínimo 6 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // Olvidé mi contraseña
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                        );
                      },
                      child: const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Botón Iniciar Sesión con Email
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      return CustomButton(
                        text: 'INICIAR SESIÓN',
                        isLoading: auth.isLoading,
                        onPressed: () async {
                          if (formKey.currentState?.validate() ?? false) {
                            final success = await auth.loginWithEmail(
                              emailController.text,
                              passwordController.text,
                            );
                            if (!context.mounted) return;

                            if (success) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                              );
                            } else if (auth.status == AuthStatus.unverifiedEmail) {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const EmailVerificationScreen()),
                              );
                            }
                          }
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Acceso Biométrico Rápido (Face ID / Huella)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                      side: const BorderSide(color: AppColors.secondary, width: 1.5),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.fingerprint, size: 24),
                    label: const Text(
                      'ACCESO RÁPIDO BIOMÉTRICO',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    onPressed: () async {
                      final authenticated = await BiometricService().authenticate(
                        localizedReason: 'Identifícate con tu huella digital o Face ID para entrar a FitPulse',
                      );
                      if (authenticated && context.mounted) {
                        await context.read<AuthProvider>().loginWithEmail('atleta.biometrico@fitpulse.club', '123456');
                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                          );
                        }
                      }
                    },
                  ),

                  const SizedBox(height: 28),

                  // Divisor Social
                  Row(
                    children: const [
                      Expanded(child: Divider(color: Colors.white24)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: Text('O CONTINÚA CON', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(child: Divider(color: Colors.white24)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Proveedores de Autenticación Social (Google & GitHub)
                  Row(
                    children: [
                      // Google
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white24),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () async {
                            final success = await context.read<AuthProvider>().signInWithGoogle();
                            if (success && context.mounted) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                              );
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.g_mobiledata, color: Colors.redAccent, size: 28),
                              SizedBox(width: 4),
                              Text('Google', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // GitHub
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white24),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () async {
                            final success = await context.read<AuthProvider>().signInWithGitHub();
                            if (success && context.mounted) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                              );
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.code, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text('GitHub', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Enlace a Registro
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('¿Aún no tienes cuenta? ', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          );
                        },
                        child: const Text(
                          'Regístrate aquí',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
