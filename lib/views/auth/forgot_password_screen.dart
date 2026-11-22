import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Contraseña'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Form(
            key: formKey,
            child: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.lock_reset, size: 64, color: AppColors.primary),
                    const SizedBox(height: 20),
                    const Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Ingresa el correo electrónico asociado a tu cuenta y te enviaremos las instrucciones de restablecimiento.',
                      style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    if (auth.errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.error),
                        ),
                        child: Text(auth.errorMessage!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                      ),

                    if (auth.successMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.success),
                        ),
                        child: Text(auth.successMessage!, style: const TextStyle(color: AppColors.success, fontSize: 13)),
                      ),

                    CustomTextField(
                      controller: emailController,
                      label: 'Correo Registrado',
                      hint: 'usuario@fitpulse.club',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Ingresa tu correo';
                        if (!val.contains('@')) return 'Ingresa un correo válido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    CustomButton(
                      text: 'ENVIAR ENLACE DE RECUPERACIÓN',
                      isLoading: auth.isLoading,
                      onPressed: () async {
                        if (formKey.currentState?.validate() ?? false) {
                          await auth.sendPasswordResetEmail(emailController.text);
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
