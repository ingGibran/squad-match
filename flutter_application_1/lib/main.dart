import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'screens/auth/auth_widgets.dart';
import 'screens/auth/login_screen.dart';
import 'services/auth_controller.dart';
import 'services/auth_repository.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SyncPlayApp());
}

class SyncPlayApp extends StatefulWidget {
  const SyncPlayApp({super.key});

  @override
  State<SyncPlayApp> createState() => _SyncPlayAppState();
}

class _SyncPlayAppState extends State<SyncPlayApp> {
  // Para conectar tu backend, cambia LocalAuthRepository() por tu propia
  // implementación de AuthRepository (Firebase, Supabase, tu API...).
  late final AuthController _auth = AuthController(LocalAuthRepository())
    ..init();

  @override
  void dispose() {
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScope(
      controller: _auth,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SyncPlay',
        theme: buildTheme(),
        home: const _Root(),
      ),
    );
  }
}

/// Elige qué mostrar: carga inicial, login o la app principal.
class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    final user = auth.user;

    final Widget page;
    if (!auth.ready) {
      page = const _Splash(key: ValueKey('splash'));
    } else if (user == null) {
      page = const LoginScreen(key: ValueKey('login'));
    } else {
      // La clave por usuario reinicia las pestañas si cambia de cuenta.
      page = AppShell(key: ValueKey(user.id));
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: page,
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthBackground(child: Center(child: AuthLogo(size: 72)));
  }
}
