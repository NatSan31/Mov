import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'email_verification_screen.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Únete a FitPulse Club',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Regístrate con tu correo y confirma tu identidad para acceder.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  // Mensaje de Error
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      if (auth.errorMessage != null) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 18),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.error),
                          ),
                          child: Text(
                            auth.errorMessage!,
                            style: const TextStyle(color: AppColors.error, fontSize: 13),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  CustomTextField(
                    controller: nameController,
                    label: 'Nombre Completo',
                    hint: 'Juan Pérez',
                    prefixIcon: Icons.person_outline,
                    validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa tu nombre' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: emailController,
                    label: 'Correo Electrónico',
                    hint: 'atleta@fitpulse.club',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Ingresa tu correo';
                      if (!val.contains('@')) return 'Correo no válido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: passwordController,
                    label: 'Contraseña',
                    hint: '••••••••',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Ingresa una contraseña';
                      if (val.length < 6) return 'Mínimo 6 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: confirmPasswordController,
                    label: 'Confirmar Contraseña',
                    hint: '••••••••',
                    prefixIcon: Icons.lock_reset,
                    obscureText: true,
                    validator: (val) {
                      if (val != passwordController.text) return 'Las contraseñas no coinciden';
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      return CustomButton(
                        text: 'REGISTRARME',
                        isLoading: auth.isLoading,
                        onPressed: () async {
                          if (formKey.currentState?.validate() ?? false) {
                            final success = await auth.registerWithEmail(
                              emailController.text,
                              passwordController.text,
                              nameController.text,
                            );

                            if (success && context.mounted) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => const EmailVerificationScreen()),
                              );
                            }
                          }
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('¿Ya tienes una cuenta? ', style: TextStyle(color: Colors.grey)),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Inicia Sesión',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
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
