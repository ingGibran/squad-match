import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override
  String toString() => message;
}

/// Contrato que usa la app. Hoy lo implementa [LocalAuthRepository]
/// (datos guardados en el dispositivo). Cuando tengas backend, crea otra
/// clase que implemente esto con Firebase Auth / Supabase y cámbiala en
/// main.dart: ninguna pantalla tendrá que modificarse.
abstract class AuthRepository {
  Future<UserProfile?> restoreSession();
  Future<UserProfile> signIn(String email, String password);
  Future<UserProfile> register(UserProfile draft, String password);
  Future<UserProfile> updateProfile(UserProfile profile);
  Future<void> signOut();
  Future<bool> isEmailAvailable(String email);
  Future<bool> isUsernameAvailable(String username);
}

/// Implementación local para desarrollo y pruebas.
/// Guarda las cuentas en el dispositivo con la contraseña convertida en un
/// hash con sal (nunca en texto plano). Es práctica para prototipar, pero no
/// sustituye a un servidor: las cuentas no se comparten entre dispositivos.
class LocalAuthRepository implements AuthRepository {
  static const _kAccounts = 'sp_accounts';
  static const _kSession = 'sp_session';

  String _norm(String email) => email.trim().toLowerCase();

  Map<String, dynamic> _readAccounts(SharedPreferences p) {
    final raw = p.getString(_kAccounts);
    if (raw == null) return {};
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  Future<void> _writeAccounts(
          SharedPreferences p, Map<String, dynamic> accounts) =>
      p.setString(_kAccounts, jsonEncode(accounts));

  String _newSalt() {
    final r = Random.secure();
    return base64UrlEncode(List<int>.generate(16, (_) => r.nextInt(256)));
  }

  String _hash(String password, String salt) {
    final bytes = utf8.encode('$salt:$password');
    var digest = sha256.convert(bytes);
    for (var i = 0; i < 5000; i++) {
      digest = sha256.convert([...digest.bytes, ...bytes]);
    }
    return digest.toString();
  }

  UserProfile _profileOf(Map<String, dynamic> record) => UserProfile.fromJson(
      Map<String, dynamic>.from(record['profile'] as Map));

  Future<void> _fakeLatency() =>
      Future<void>.delayed(const Duration(milliseconds: 450));

  @override
  Future<UserProfile?> restoreSession() async {
    final p = await SharedPreferences.getInstance();
    final email = p.getString(_kSession);
    if (email == null) return null;
    final record = _readAccounts(p)[email];
    if (record == null) return null;
    return _profileOf(Map<String, dynamic>.from(record as Map));
  }

  @override
  Future<UserProfile> signIn(String email, String password) async {
    await _fakeLatency();
    final p = await SharedPreferences.getInstance();
    final key = _norm(email);
    final raw = _readAccounts(p)[key];
    const generic = AuthException('Correo o contraseña incorrectos.');
    if (raw == null) throw generic;
    final record = Map<String, dynamic>.from(raw as Map);
    if (_hash(password, record['salt'] as String) != record['hash']) {
      throw generic;
    }
    await p.setString(_kSession, key);
    return _profileOf(record);
  }

  @override
  Future<UserProfile> register(UserProfile draft, String password) async {
    await _fakeLatency();
    final p = await SharedPreferences.getInstance();
    final accounts = _readAccounts(p);
    final key = _norm(draft.email);

    if (accounts.containsKey(key)) {
      throw const AuthException('Ya existe una cuenta con este correo.');
    }
    final taken = accounts.values.any((r) =>
        _profileOf(Map<String, dynamic>.from(r as Map)).username.toLowerCase() ==
        draft.username.toLowerCase());
    if (taken) {
      throw const AuthException('Ese nombre de usuario ya está en uso.');
    }

    final profile = draft.copyWith(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
    );
    final salt = _newSalt();
    accounts[key] = {
      'profile': profile.toJson(),
      'salt': salt,
      'hash': _hash(password, salt),
    };
    await _writeAccounts(p, accounts);
    await p.setString(_kSession, key);
    return profile;
  }

  @override
  Future<UserProfile> updateProfile(UserProfile profile) async {
    final p = await SharedPreferences.getInstance();
    final accounts = _readAccounts(p);
    final key = _norm(profile.email);
    final raw = accounts[key];
    if (raw == null) throw const AuthException('No se encontró tu cuenta.');
    final record = Map<String, dynamic>.from(raw as Map);
    record['profile'] = profile.toJson();
    accounts[key] = record;
    await _writeAccounts(p, accounts);
    return profile;
  }

  @override
  Future<void> signOut() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kSession);
  }

  @override
  Future<bool> isEmailAvailable(String email) async {
    final p = await SharedPreferences.getInstance();
    return !_readAccounts(p).containsKey(_norm(email));
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    final p = await SharedPreferences.getInstance();
    final u = username.trim().toLowerCase();
    return !_readAccounts(p).values.any((r) =>
        _profileOf(Map<String, dynamic>.from(r as Map)).username.toLowerCase() ==
        u);
  }
}
