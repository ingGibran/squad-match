// Pestaña "Perfil" de SyncPlay.
// Todo lo que se ve aquí sale del usuario que inició sesión (AuthScope).
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/catalog.dart';
import '../models/user_profile.dart';
import '../services/auth_controller.dart';
import '../theme.dart';
import '../widgets.dart';
import 'auth/auth_widgets.dart';

/// Medallas: la primera se obtiene al registrarse; el resto se desbloquean
/// con la actividad real (cuando conectes el backend).
const _medals = <(IconData, String, Color)>[
  (Icons.celebration_rounded, 'Nuevo en SyncPlay', C.primary),
  (Icons.favorite_rounded, 'Primer dúo', Color(0xFFFF5AA5)),
  (Icons.local_fire_department_rounded, 'Racha de 7 días', Color(0xFFFF6B3D)),
  (Icons.military_tech_rounded, 'Primer clutch', C.amber),
  (Icons.groups_rounded, 'Líder de squad', C.online),
  (Icons.verified_rounded, 'Verificado', Color(0xFF6BA8FF)),
];

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _tab = 0;

  static const _tabs = [
    (Icons.play_circle_outline_rounded, 'Clips'),
    (Icons.workspace_premium_outlined, 'Medallas'),
    (Icons.groups_outlined, 'Squads'),
    (Icons.bookmark_border_rounded, 'Guardados'),
  ];

  // ── Acciones
  Future<void> _editProfile(UserProfile user) async {
    final result = await showModalBottomSheet<UserProfile>(
      context: context,
      isScrollControlled: true,
      backgroundColor: C.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _EditSheet(user: user),
    );
    if (result == null || !mounted) return;
    await AuthScope.read(context).updateProfile(result);
    if (!mounted) return;
    _toast('Perfil actualizado');
  }

  void _showQr(UserProfile user) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: C.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tu código de dúo',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(16)),
              // Reemplázalo por un QR real con el paquete qr_flutter.
              child: const Icon(Icons.qr_code_2_rounded,
                  size: 160, color: Colors.black),
            ),
            const SizedBox(height: 12),
            Text('@${user.username}', style: const TextStyle(color: C.muted)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: '@${user.username}'));
              Navigator.pop(ctx);
              _toast('Usuario copiado');
            },
            child: const Text('Copiar usuario'),
          ),
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  void _openSettings(UserProfile user) {
    final pal = kAvatarPalette[user.avatarColor % kAvatarPalette.length];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: C.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                    color: C.border, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Avatar(name: user.displayName, size: 44, c1: pal.$1, c2: pal.$2),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: C.text)),
                      Text('Miembro desde ${user.createdAt.year}',
                          style:
                              const TextStyle(fontSize: 12, color: C.muted)),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              const Divider(color: C.border),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.logout_rounded, color: kError),
                title: const Text('Cerrar sesión',
                    style: TextStyle(
                        color: kError, fontWeight: FontWeight.w700)),
                onTap: () {
                  Navigator.pop(ctx);
                  AuthScope.read(context).signOut();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: C.surfaceHi,
      ));
  }

  // ── UI
  @override
  Widget build(BuildContext context) {
    final user = AuthScope.of(context).user;
    if (user == null) return const SizedBox.shrink();

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          SyncTopBar(section: 'Perfil', actions: [
            IconButton(
              tooltip: 'Ajustes de cuenta',
              onPressed: () => _openSettings(user),
              icon: const Icon(Icons.tune_rounded, color: C.muted),
            ),
          ]),
          _bannerAndAvatar(user),
          _identity(user),
          _connectionCard(user),
          _stats(user),
          _gamesSection(user),
          _contentTabs(),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: KeyedSubtree(key: ValueKey(_tab), child: _tabContent(user)),
          ),
        ],
      ),
    );
  }

  Widget _bannerAndAvatar(UserProfile user) {
    final pal = kAvatarPalette[user.avatarColor % kAvatarPalette.length];
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [pal.$1.withAlpha(140), pal.$2, C.bg],
            ),
          ),
        ),
        Positioned(
          right: 12,
          bottom: 10,
          child: Material(
            color: const Color(0x99000000),
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => _toast('Elegir banner: próximamente'),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                child: Row(children: [
                  Icon(Icons.photo_camera_outlined, size: 14, color: C.text),
                  SizedBox(width: 6),
                  Text('Cambiar banner',
                      style: TextStyle(fontSize: 11.5, color: C.text)),
                ]),
              ),
            ),
          ),
        ),
        Positioned(
          left: 16,
          bottom: -42,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration:
                const BoxDecoration(color: C.bg, shape: BoxShape.circle),
            child: Avatar(
              name: user.displayName,
              size: 80,
              online: true,
              c1: pal.$1,
              c2: pal.$2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _identity(UserProfile user) {
    final firstPlatform = user.platforms.isEmpty
        ? null
        : platformById(user.platforms.first).label;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 52,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _SoftButton(
                    icon: Icons.edit_outlined,
                    label: 'Editar Perfil',
                    onTap: () => _editProfile(user)),
                const SizedBox(width: 8),
                _SquareIconButton(
                    icon: Icons.qr_code_2_rounded,
                    tooltip: 'Mostrar QR',
                    onTap: () => _showQr(user)),
                const SizedBox(width: 8),
                _SquareIconButton(
                    icon: Icons.shield_outlined,
                    tooltip: 'Privacidad',
                    onTap: () => _toast('Privacidad: próximamente')),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(user.displayName,
                  style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: C.text,
                      letterSpacing: -0.3)),
              if (user.verified)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                      color: C.primarySoft,
                      borderRadius: BorderRadius.circular(20)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.verified_rounded, size: 12, color: C.primary),
                    SizedBox(width: 4),
                    Text('Verificado',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: C.primary)),
                  ]),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Row(children: [
            Text('@${user.username}',
                style: const TextStyle(fontSize: 12.5, color: C.primary)),
            const SizedBox(width: 10),
            const Icon(Icons.circle, size: 8, color: C.online),
            const SizedBox(width: 5),
            Text(firstPlatform == null ? 'En línea' : 'Online en $firstPlatform',
                style: const TextStyle(fontSize: 12.5, color: C.online)),
          ]),
          const SizedBox(height: 10),
          if (user.bio.isEmpty)
            GestureDetector(
              onTap: () => _editProfile(user),
              child: const Text(
                'Agrega una bio para que otros jugadores te conozcan.',
                style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: C.muted,
                    fontStyle: FontStyle.italic),
              ),
            )
          else
            Text(user.bio,
                style: const TextStyle(
                    fontSize: 13, height: 1.45, color: C.muted)),
        ],
      ),
    );
  }

  Widget _connectionCard(UserProfile user) {
    final hasTag = user.gamerTag.isNotEmpty;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  color: C.primarySoft,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.headset_mic_rounded,
                  size: 17, color: C.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: hasTag ? null : () => _editProfile(user),
                child: Text(
                    hasTag ? user.gamerTag : 'Agrega tu ID de juego',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: hasTag ? C.text : C.muted)),
              ),
            ),
            if (hasTag)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: const Color(0x223DDC84),
                    borderRadius: BorderRadius.circular(6)),
                child: const Text('Conectado',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: C.online)),
              ),
          ]),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final id in user.platforms)
              _PlatformChip(
                  platformById(id).icon, platformById(id).label),
          ]),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: C.border),
          ),
          Row(children: [
            const Icon(Icons.schedule_rounded, size: 15, color: C.muted),
            const SizedBox(width: 8),
            Expanded(
              child: Text('${user.region} • ${user.scheduleLabel}',
                  style: const TextStyle(fontSize: 12, color: C.muted)),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _stats(UserProfile user) {
    Widget stat(Widget value, String label) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: _cardDecoration,
            child: Column(children: [
              value,
              const SizedBox(height: 3),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 10, color: C.muted, letterSpacing: 0.2)),
            ]),
          ),
        );

    TextStyle big(Color c) =>
        TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: c);

    // Karma y reputación se calculan con la actividad real: hasta que haya
    // partidas jugadas se muestran en blanco.
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(children: [
        stat(Text('${user.duoGames}', style: big(C.primary)), 'Partidas dúo'),
        const SizedBox(width: 8),
        stat(Text('—', style: big(C.muted)), 'Karma positivo'),
        const SizedBox(width: 8),
        stat(
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('—', style: big(C.muted)),
            const SizedBox(width: 2),
            const Icon(Icons.star_rounded, size: 18, color: C.muted),
          ]),
          'Reputación',
        ),
      ]),
    );
  }

  Widget _gamesSection(UserProfile user) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('Juegos principales',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800, color: C.text)),
            const Spacer(),
            Text('${user.games.length} títulos',
                style: const TextStyle(fontSize: 11, color: C.muted)),
          ]),
          const SizedBox(height: 10),
          if (user.games.isEmpty)
            const Text('Aún no elegiste juegos principales.',
                style: TextStyle(fontSize: 12.5, color: C.muted)),
          for (final entry in user.games) ...[
            _GameTile(entry: entry),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _contentTabs() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      padding: const EdgeInsets.all(4),
      decoration: _cardDecoration,
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final sel = i == _tab;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _tab = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: sel ? C.primarySoft : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_tabs[i].$1,
                        size: 15, color: sel ? C.primary : C.muted),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(_tabs[i].$2,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: sel ? C.primary : C.muted)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _tabContent(UserProfile user) {
    switch (_tab) {
      case 0:
        return const _EmptyBlock(
          icon: Icons.videocam_outlined,
          title: 'Aún no subiste clips',
          message: 'Tus mejores jugadas aparecerán aquí.',
        );
      case 1:
        return _medalsGrid(user);
      case 2:
        return const _EmptyBlock(
          icon: Icons.groups_outlined,
          title: 'Todavía no estás en ningún squad',
          message: 'Únete o crea uno desde Descubrir.',
        );
      default:
        return const _EmptyBlock(
          icon: Icons.bookmark_border_rounded,
          title: 'Aún no guardaste nada',
          message: 'Toca el marcador en un clip o perfil para verlo aquí.',
        );
    }
  }

  Widget _medalsGrid(UserProfile user) {
    bool unlocked(int i) =>
        i == 0 ||
        (_medals[i].$2 == 'Verificado' && user.verified) ||
        (_medals[i].$2 == 'Primer dúo' && user.duoGames > 0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
        children: [
          for (var i = 0; i < _medals.length; i++)
            Opacity(
              opacity: unlocked(i) ? 1 : 0.4,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: _cardDecoration,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(unlocked(i) ? _medals[i].$1 : Icons.lock_outline_rounded,
                        size: 28,
                        color: unlocked(i) ? _medals[i].$3 : C.muted),
                    const SizedBox(height: 6),
                    Text(_medals[i].$2,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: C.text)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// ───────────────────────── Piezas pequeñas ─────────────────────────
final _cardDecoration = BoxDecoration(
  color: C.surface,
  borderRadius: BorderRadius.circular(16),
  border: Border.all(color: C.border),
);

class _SoftButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SoftButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: C.primarySoft,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 15, color: C.primary),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: C.primary)),
          ]),
        ),
      ),
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _SquareIconButton(
      {required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: C.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: C.border),
            ),
            child: Icon(icon, size: 19, color: C.primary),
          ),
        ),
      ),
    );
  }
}

class _PlatformChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PlatformChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: C.surfaceHi,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: C.border)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: C.muted),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11.5, color: C.text)),
      ]),
    );
  }
}

class _GameTile extends StatelessWidget {
  final GameEntry entry;
  const _GameTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final game = gameById(entry.gameId);
    final ranked = entry.rank != kRanks.first;
    final badgeColor = ranked ? game.color : C.muted;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration,
      child: Row(children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
              color: game.color.withAlpha(38),
              borderRadius: BorderRadius.circular(11)),
          child: Icon(game.icon, size: 20, color: game.color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(game.title,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: C.text)),
              const SizedBox(height: 2),
              Text(game.mode,
                  style: const TextStyle(fontSize: 11.5, color: C.muted)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
              color: badgeColor.withAlpha(38),
              borderRadius: BorderRadius.circular(6)),
          child: Text(ranked ? entry.rank.toUpperCase() : 'CASUAL',
              style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: badgeColor)),
        ),
      ]),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const _EmptyBlock(
      {required this.icon, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 32),
      child: Column(children: [
        Icon(icon, size: 38, color: C.muted),
        const SizedBox(height: 10),
        Text(title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: C.text)),
        const SizedBox(height: 4),
        Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: C.muted)),
      ]),
    );
  }
}

/// Hoja inferior para editar nombre, bio, ID de juego y color de avatar.
class _EditSheet extends StatefulWidget {
  final UserProfile user;
  const _EditSheet({required this.user});

  @override
  State<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<_EditSheet> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.user.displayName);
  late final _bio = TextEditingController(text: widget.user.bio);
  late final _tag = TextEditingController(text: widget.user.gamerTag);
  late int _color = widget.user.avatarColor;

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    _tag.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    Navigator.pop(
      context,
      widget.user.copyWith(
        displayName: _name.text.trim(),
        bio: _bio.text.trim(),
        gamerTag: _tag.text.trim(),
        avatarColor: _color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                      color: C.border, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Editar perfil',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              const FieldLabel('Color de tu avatar'),
              AvatarColorPicker(
                  selected: _color,
                  onChanged: (i) => setState(() => _color = i)),
              const SizedBox(height: 16),
              AuthField(
                controller: _name,
                label: 'Nombre visible',
                icon: Icons.person_outline_rounded,
                action: TextInputAction.next,
                validator: validateDisplayName,
              ),
              const SizedBox(height: 12),
              AuthField(
                controller: _tag,
                label: 'ID de juego',
                hint: 'novarogue#0001',
                icon: Icons.headset_mic_rounded,
                action: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              AuthField(
                controller: _bio,
                label: 'Bio',
                icon: Icons.notes_rounded,
                maxLines: 3,
                maxLength: 160,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: C.border),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: const Text('Cancelar',
                        style: TextStyle(color: C.muted)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                        backgroundColor: C.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: const Text('Guardar cambios'),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
