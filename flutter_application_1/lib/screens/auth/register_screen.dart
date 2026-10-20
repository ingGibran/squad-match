import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/catalog.dart';
import '../../models/user_profile.dart';
import '../../services/auth_controller.dart';
import '../../theme.dart';
import '../../widgets.dart';
import 'auth_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const _titles = [
    ('Crea tu cuenta', 'Usa tu correo para entrar a SyncPlay.'),
    ('Cuéntanos quién eres', 'Así te verán otros jugadores.'),
    ('Tu perfil gamer', 'Con esto te buscamos el dúo ideal.'),
  ];
  static const _maxGames = 5;

  final _keys = List.generate(3, (_) => GlobalKey<FormState>());
  int _step = 0;
  bool _loading = false;
  String? _error;
  String? _emailTaken;
  String? _usernameTaken;

  // Paso 1
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  // Paso 2
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _bio = TextEditingController();
  int _avatarColor = 0;
  // Paso 3
  final _tag = TextEditingController();
  final Set<String> _platforms = {};
  final List<String> _games = [];
  final Map<String, String> _ranks = {};
  String _region = kRegions.first;
  final Set<int> _days = {0, 1, 2, 3, 4, 5, 6};
  TimeOfDay _start = const TimeOfDay(hour: 21, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 1, minute: 0);

  @override
  void dispose() {
    for (final c in [_email, _pass, _confirm, _name, _username, _bio, _tag]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Navegación entre pasos
  void _back() {
    FocusScope.of(context).unfocus();
    if (_step == 0) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _step--;
        _error = null;
      });
    }
  }

  Future<void> _next() async {
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    if (!_keys[_step].currentState!.validate()) return;
    final auth = AuthScope.read(context);

    if (_step == 0) {
      setState(() => _loading = true);
      final free = await auth.isEmailAvailable(_email.text);
      if (!mounted) return;
      setState(() => _loading = false);
      if (!free) {
        _emailTaken = 'Ya existe una cuenta con este correo.';
        _keys[0].currentState!.validate();
        return;
      }
      setState(() => _step = 1);
    } else if (_step == 1) {
      setState(() => _loading = true);
      final free = await auth.isUsernameAvailable(_username.text);
      if (!mounted) return;
      setState(() => _loading = false);
      if (!free) {
        _usernameTaken = 'Ese usuario ya está en uso.';
        _keys[1].currentState!.validate();
        return;
      }
      setState(() => _step = 2);
    } else {
      await _submit(auth);
    }
  }

  Future<void> _submit(AuthController auth) async {
    if (_platforms.isEmpty) {
      setState(() => _error = 'Elige al menos una plataforma.');
      return;
    }
    if (_games.isEmpty) {
      setState(() => _error = 'Elige al menos un juego principal.');
      return;
    }
    if (_days.isEmpty) {
      setState(() => _error = 'Elige al menos un día de juego.');
      return;
    }

    final draft = UserProfile(
      id: '',
      email: _email.text.trim(),
      displayName: _name.text.trim(),
      username: _username.text.trim(),
      bio: _bio.text.trim(),
      gamerTag: _tag.text.trim(),
      platforms: kPlatforms
          .map((p) => p.id)
          .where(_platforms.contains)
          .toList(),
      games: [for (final id in _games) GameEntry(id, _ranks[id] ?? kRanks.first)],
      region: _region,
      days: (_days.toList()..sort()),
      startMinutes: _start.hour * 60 + _start.minute,
      endMinutes: _end.hour * 60 + _end.minute,
      avatarColor: _avatarColor,
      createdAt: DateTime.now(),
    );

    setState(() => _loading = true);
    final err = await auth.register(draft, _pass.text);
    if (!mounted) return;
    if (err != null) {
      setState(() {
        _loading = false;
        _error = err;
      });
      return;
    }
    // La cuenta ya está creada y la app cambió a la pantalla principal
    // por debajo: cerramos esta ruta para dejarla a la vista.
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  // ── Interacciones del paso 3
  void _toggleSet<T>(Set<T> set, T value) {
    setState(() {
      _error = null;
      if (!set.add(value)) set.remove(value);
    });
  }

  void _toggleGame(String id) {
    setState(() {
      _error = null;
      if (_games.contains(id)) {
        _games.remove(id);
        _ranks.remove(id);
      } else if (_games.length >= _maxGames) {
        _error = 'Puedes elegir hasta $_maxGames juegos principales.';
      } else {
        _games.add(id);
        _ranks[id] = kRanks.first;
      }
    });
  }

  Future<void> _pickTime({required bool start}) async {
    final t = await showTimePicker(
        context: context, initialTime: start ? _start : _end);
    if (t == null) return;
    setState(() {
      if (start) {
        _start = t;
      } else {
        _end = t;
      }
    });
  }

  // ── UI
  @override
  Widget build(BuildContext context) {
    final (title, subtitle) = _titles[_step];
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: AuthBackground(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 20, 0),
              child: Row(children: [
                IconButton(
                  onPressed: _back,
                  icon: const Icon(Icons.arrow_back_rounded, color: C.text),
                ),
                Expanded(
                  child: Row(
                    children: List.generate(3, (i) {
                      return Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          height: 4,
                          margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                          decoration: BoxDecoration(
                            color: i <= _step ? C.primary : C.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ]),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Paso ${_step + 1} de 3',
                            style: const TextStyle(
                                fontSize: 12, color: C.primary)),
                        const SizedBox(height: 6),
                        Text(title,
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: C.text,
                                letterSpacing: -0.4)),
                        const SizedBox(height: 4),
                        Text(subtitle,
                            style: const TextStyle(
                                fontSize: 13.5, color: C.muted)),
                        const SizedBox(height: 24),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: KeyedSubtree(
                            key: ValueKey(_step),
                            child: Form(
                              key: _keys[_step],
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: switch (_step) {
                                  0 => _stepAccount(),
                                  1 => _stepIdentity(),
                                  _ => _stepGaming(),
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_error != null) ...[
                      ErrorBanner(_error!),
                      const SizedBox(height: 10),
                    ],
                    PrimaryButton(
                      label: _step == 2 ? 'Crear cuenta' : 'Continuar',
                      loading: _loading,
                      onPressed: _next,
                    ),
                    if (_step == 0)
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('¿Ya tienes cuenta? Inicia sesión',
                            style: TextStyle(fontSize: 12.5, color: C.muted)),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Paso 1: cuenta
  List<Widget> _stepAccount() => [
        AuthField(
          controller: _email,
          label: 'Correo electrónico',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          action: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          onChanged: (_) {
            if (_emailTaken != null) setState(() => _emailTaken = null);
          },
          validator: (v) => validateEmail(v) ?? _emailTaken,
        ),
        const SizedBox(height: 14),
        AuthField(
          controller: _pass,
          label: 'Contraseña',
          helper: 'Mínimo 8 caracteres, con letras y números.',
          icon: Icons.lock_outline_rounded,
          password: true,
          action: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
          validator: validateNewPassword,
        ),
        const SizedBox(height: 14),
        AuthField(
          controller: _confirm,
          label: 'Repite la contraseña',
          icon: Icons.lock_outline_rounded,
          password: true,
          action: TextInputAction.done,
          onSubmitted: (_) => _next(),
          validator: (v) =>
              v != _pass.text ? 'Las contraseñas no coinciden.' : null,
        ),
      ];

  // ── Paso 2: identidad
  List<Widget> _stepIdentity() {
    final pal = kAvatarPalette[_avatarColor];
    return [
      Row(children: [
        Avatar(
          name: _name.text.isEmpty ? '?' : _name.text,
          size: 72,
          c1: pal.$1,
          c2: pal.$2,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FieldLabel('Color de tu avatar'),
              AvatarColorPicker(
                selected: _avatarColor,
                onChanged: (i) => setState(() => _avatarColor = i),
              ),
            ],
          ),
        ),
      ]),
      const SizedBox(height: 22),
      AuthField(
        controller: _name,
        label: 'Nombre visible',
        hint: 'Ej. Elena “Nova” Rostova',
        icon: Icons.person_outline_rounded,
        action: TextInputAction.next,
        onChanged: (_) => setState(() {}),
        validator: validateDisplayName,
      ),
      const SizedBox(height: 14),
      AuthField(
        controller: _username,
        label: 'Nombre de usuario',
        prefixText: '@',
        icon: Icons.alternate_email_rounded,
        action: TextInputAction.next,
        formatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]'))],
        onChanged: (_) {
          if (_usernameTaken != null) setState(() => _usernameTaken = null);
        },
        validator: (v) => validateUsername(v) ?? _usernameTaken,
      ),
      const SizedBox(height: 14),
      AuthField(
        controller: _bio,
        label: 'Bio (opcional)',
        hint: 'Rol, rango, horarios, qué buscas en un dúo...',
        icon: Icons.notes_rounded,
        maxLines: 3,
        maxLength: 160,
        keyboardType: TextInputType.multiline,
      ),
    ];
  }

  // ── Paso 3: perfil gamer
  List<Widget> _stepGaming() => [
        AuthField(
          controller: _tag,
          label: 'ID de juego (opcional)',
          hint: 'novarogue#0001',
          icon: Icons.headset_mic_rounded,
          action: TextInputAction.done,
        ),
        const SizedBox(height: 22),
        const FieldLabel('Plataformas'),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final p in kPlatforms)
            SelectChip(
              label: p.label,
              icon: p.icon,
              selected: _platforms.contains(p.id),
              onTap: () => _toggleSet(_platforms, p.id),
            ),
        ]),
        const SizedBox(height: 22),
        FieldLabel('Juegos principales',
            trailing: '${_games.length}/$_maxGames'),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final g in kGames)
            SelectChip(
              label: g.title,
              icon: g.icon,
              selected: _games.contains(g.id),
              onTap: () => _toggleGame(g.id),
            ),
        ]),
        if (_games.isNotEmpty) ...[
          const SizedBox(height: 14),
          for (final id in _games) _rankRow(id),
        ],
        const SizedBox(height: 22),
        DropdownButtonFormField<String>(
          value: _region,
          isExpanded: true,
          dropdownColor: C.surfaceHi,
          style: const TextStyle(color: C.text, fontSize: 15),
          decoration:
              authDecoration(label: 'Región', icon: Icons.public_rounded),
          items: [
            for (final r in kRegions) DropdownMenuItem(value: r, child: Text(r)),
          ],
          onChanged: (v) => setState(() => _region = v ?? _region),
        ),
        const SizedBox(height: 22),
        const FieldLabel('Días en los que juegas'),
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (var i = 0; i < kDays.length; i++)
            SelectChip(
              label: kDays[i],
              selected: _days.contains(i),
              onTap: () => _toggleSet(_days, i),
            ),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
              child: _TimeBox(
                  label: 'Desde',
                  time: _start,
                  onTap: () => _pickTime(start: true))),
          const SizedBox(width: 10),
          Expanded(
              child: _TimeBox(
                  label: 'Hasta',
                  time: _end,
                  onTap: () => _pickTime(start: false))),
        ]),
      ];

  Widget _rankRow(String id) {
    final g = gameById(id);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: C.border),
      ),
      child: Row(children: [
        Icon(g.icon, size: 18, color: g.color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(g.title,
              style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: C.text)),
        ),
        DropdownButton<String>(
          value: _ranks[id] ?? kRanks.first,
          isDense: true,
          underline: const SizedBox.shrink(),
          dropdownColor: C.surfaceHi,
          style: const TextStyle(fontSize: 12.5, color: C.primary),
          items: [
            for (final r in kRanks) DropdownMenuItem(value: r, child: Text(r)),
          ],
          onChanged: (v) => setState(() => _ranks[id] = v ?? kRanks.first),
        ),
      ]),
    );
  }
}

class _TimeBox extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;
  const _TimeBox(
      {required this.label, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final text =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    return Material(
      color: C.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: C.border),
          ),
          child: Row(children: [
            const Icon(Icons.schedule_rounded, size: 18, color: C.muted),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: const TextStyle(fontSize: 10.5, color: C.muted)),
              Text(text,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: C.text)),
            ]),
          ]),
        ),
      ),
    );
  }
}
