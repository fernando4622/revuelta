import 'package:flutter/material.dart';
import '../shared/theme/app_colors.dart';
import 'verify_email_page.dart';

/// Screen representing "Crear cuenta / Registro" (Mockup Screen 7).
/// Captures Full Name, Institutional Email, Password, and proceeds to email verification.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VerifyEmailPage(email: _emailController.text.trim()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Crear cuenta',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Usa tu correo institucional del ITVer.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Nombre completo
                const Text(
                  'Nombre completo',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Ej. Valeria Torres',
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Ingresa tu nombre' : null,
                ),
                const SizedBox(height: 16),

                // Correo institucional
                const Text(
                  'Correo institucional',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'tu.correo@itver.edu.mx',
                  ),
                  validator: (val) => val == null || val.isEmpty
                      ? 'Ingresa tu correo institucional'
                      : null,
                ),
                const SizedBox(height: 16),

                // Contraseña
                const Text(
                  'Contraseña',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Min. 8 caracteres',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (val) => val == null || val.length < 8
                      ? 'Mínimo 8 caracteres'
                      : null,
                ),
                const SizedBox(height: 28),

                // Botón Registrarse
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forestGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _submit,
                  child: const Text('Registrarse'),
                ),
                const SizedBox(height: 20),

                // Legal note
                const Text(
                  'Al registrarte aceptas nuestros\nTérminos y Condiciones y Aviso de Privacidad.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
