import 'package:flutter/material.dart';

import '../../services/auth_controller.dart';
import '../../theme.dart';
import 'auth_widgets.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final err =
        await AuthScope.read(context).signIn(_email.text, _pass.text);
    if (!mounted) return;
    // Si salió bien, la app cambia sola a la pantalla principal.
    if (err != null) {
      setState(() {
        _loading = false;
        _error = err;
      });
    }
  }

  void _forgotPassword() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: C.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Recuperar contraseña',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        content: const Text(
          'Esta versión guarda las cuentas en tu dispositivo, así que todavía '
          'no puede enviar correos de recuperación. Se activará cuando '
          'conectes el servidor (Firebase o Supabase).',
          style: TextStyle(color: C.muted, height: 1.4),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Entendido')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: AuthLogo()),
                  const SizedBox(height: 32),
                  const Text('Bienvenido de vuelta',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: C.text)),
                  const SizedBox(height: 6),
                  const Text('Inicia sesión para volver con tu squad.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13.5, color: C.muted)),
                  const SizedBox(height: 28),
                  AuthField(
                    controller: _email,
                    label: 'Correo electrónico',
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    action: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    validator: validateEmail,
                  ),
                  const SizedBox(height: 14),
                  AuthField(
                    controller: _pass,
                    label: 'Contraseña',
                    icon: Icons.lock_outline_rounded,
                    password: true,
                    action: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    onSubmitted: (_) => _submit(),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Escribe tu contraseña.' : null,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _forgotPassword,
                      child: const Text('¿Olvidaste tu contraseña?',
                          style: TextStyle(fontSize: 12.5, color: C.primary)),
                    ),
                  ),
                  if (_error != null) ...[
                    ErrorBanner(_error!),
                    const SizedBox(height: 12),
                  ],
                  PrimaryButton(
                      label: 'Iniciar sesión',
                      loading: _loading,
                      onPressed: _submit),
                  const SizedBox(height: 22),
                  const Row(children: [
                    Expanded(child: Divider(color: C.border)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('¿Primera vez aquí?',
                          style: TextStyle(fontSize: 12, color: C.muted)),
                    ),
                    Expanded(child: Divider(color: C.border)),
                  ]),
                  const SizedBox(height: 22),
                  SecondaryButton(
                    label: 'Crear una cuenta',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (_) => const RegisterScreen()),
                    ),
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
