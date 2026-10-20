import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import 'auth_repository.dart';

/// Guarda el usuario activo y avisa a la interfaz cuando cambia.
/// Los métodos que pueden fallar devuelven un mensaje de error (o null si
/// todo salió bien) para que las pantallas lo muestren sin try/catch.
class AuthController extends ChangeNotifier {
  AuthController(this._repo);

  final AuthRepository _repo;
  UserProfile? _user;
  bool _ready = false;

  UserProfile? get user => _user;
  bool get ready => _ready;

  Future<void> init() async {
    try {
      _user = await _repo.restoreSession();
    } catch (_) {
      _user = null;
    }
    _ready = true;
    notifyListeners();
  }

  Future<String?> signIn(String email, String password) async {
    try {
      _user = await _repo.signIn(email, password);
      notifyListeners();
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Algo salió mal. Inténtalo de nuevo.';
    }
  }

  Future<String?> register(UserProfile draft, String password) async {
    try {
      _user = await _repo.register(draft, password);
      notifyListeners();
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'No pudimos crear tu cuenta. Inténtalo de nuevo.';
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    _user = await _repo.updateProfile(profile);
    notifyListeners();
  }

  Future<void> signOut() async {
    await _repo.signOut();
    _user = null;
    notifyListeners();
  }

  Future<bool> isEmailAvailable(String email) => _repo.isEmailAvailable(email);
  Future<bool> isUsernameAvailable(String username) =>
      _repo.isUsernameAvailable(username);
}

/// Permite acceder al controlador desde cualquier pantalla:
///   AuthScope.of(context)    → se reconstruye cuando el usuario cambia
///   AuthScope.read(context)  → solo lectura, para usar en botones
class AuthScope extends InheritedNotifier<AuthController> {
  const AuthScope({
    super.key,
    required AuthController controller,
    required super.child,
  }) : super(notifier: controller);

  static AuthController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AuthScope>()!.notifier!;

  static AuthController read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AuthScope>()!.notifier!;
}
