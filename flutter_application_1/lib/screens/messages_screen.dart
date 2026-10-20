// Pestaña "Mensajes" de SyncPlay.
import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../widgets.dart';

/// ───────────────────────── Modelo ─────────────────────────
enum ChatKind { squad, duo, match }

class Pill {
  final String label;
  final Color color;
  const Pill(this.label, this.color);
}

class ChatItem {
  final String name;
  final ChatKind kind;
  final String time;
  final String preview;
  final int unread;
  final bool verified;
  final bool online;
  final bool hasGame; // partida programada / en lobby
  final List<Pill> pills;
  final Color c1;
  final Color c2;

  const ChatItem({
    required this.name,
    required this.kind,
    required this.time,
    required this.preview,
    this.unread = 0,
    this.verified = false,
    this.online = false,
    this.hasGame = false,
    this.pills = const [],
    this.c1 = C.primary,
    this.c2 = const Color(0xFF2B2F6B),
  });
}

const _chats = <ChatItem>[
  ChatItem(
    name: 'Apex Predator Squad',
    kind: ChatKind.squad,
    time: 'Hace 5 min',
    preview: 'GamerX: ¡Listos para el torneo de las 9!',
    unread: 2,
    verified: true,
    online: true,
    hasGame: true,
    pills: [
      Pill('Apex Legends • Ranked', C.muted),
      Pill('3 miembros en lobby', C.online),
    ],
    c1: Color(0xFFFF5A5F),
    c2: Color(0xFF5B1B3A),
  ),
  ChatItem(
    name: 'Valkyrie // Aim Queen',
    kind: ChatKind.duo,
    time: '18:42',
    preview: 'Propuesta: Ascendant 2 a las 22:30',
    online: true,
    hasGame: true,
    pills: [
      Pill('Valorant • Dúo Competitivo', C.muted),
      Pill('Hoy 22:30 hs', C.primary),
    ],
    c1: Color(0xFF3DD6D0),
    c2: Color(0xFF1B3A5B),
  ),
  ChatItem(
    name: 'Helldivers Protocol 9',
    kind: ChatKind.squad,
    time: 'Ayer',
    preview: 'Marcos: Extraigan rápido, viene un Bile Titan',
    pills: [Pill('Helldivers 2 • Misión Imposible', C.muted)],
    c1: Color(0xFFFFC24B),
    c2: Color(0xFF4A3A12),
  ),
  ChatItem(
    name: 'Kaelen Voss',
    kind: ChatKind.match,
    time: 'Ayer',
    preview: 'Se han conectado para jugar juntos. ¡Saluda y propón una partida!',
    online: true,
    pills: [
      Pill('Valorant', C.muted),
      Pill('96% Sinergia', C.online),
    ],
    c1: Color(0xFFB07BFF),
    c2: Color(0xFF2A1B5B),
  ),
];

const _onlineDuos = <(String, String, Color)>[
  ('ShadowVex', 'Valorant', Color(0xFF7B6CFF)),
  ('NovaStrike', 'Apex', Color(0xFF3DD6D0)),
  ('GhostRider', 'Helldivers', Color(0xFFFF8A4B)),
  ('KiraZero', 'Overwatch', Color(0xFFFF5AA5)),
  ('Zeno', 'CS2', Color(0xFF6BA8FF)),
];

/// ───────────────────────── Pantalla ─────────────────────────
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _search = TextEditingController();
  int _filter = 0;

  static const _filters = ['Todos', 'Squads', 'Dúos', 'Partidas'];

  List<ChatItem> get _visible {
    final q = _search.text.trim().toLowerCase();
    return _chats.where((c) {
      final okFilter = switch (_filter) {
        1 => c.kind == ChatKind.squad,
        2 => c.kind == ChatKind.duo || c.kind == ChatKind.match,
        3 => c.hasGame,
        _ => true,
      };
      final okSearch = q.isEmpty || c.name.toLowerCase().contains(q);
      return okFilter && okSearch;
    }).toList();
  }

  int _count(int f) => switch (f) {
        1 => _chats.where((c) => c.kind == ChatKind.squad).length,
        2 => _chats
            .where((c) => c.kind != ChatKind.squad)
            .length,
        3 => _chats.where((c) => c.hasGame).length,
        _ => 0,
      };

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chats = _visible;
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _header()),
          SliverToBoxAdapter(child: _searchBar()),
          SliverToBoxAdapter(child: _filterChips()),
          SliverToBoxAdapter(child: _onlineSection()),
          SliverToBoxAdapter(child: _inboxTitle()),
          if (chats.isEmpty)
            const SliverToBoxAdapter(child: _EmptyState())
          else
            SliverList.separated(
              itemCount: chats.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: chats[i].kind == ChatKind.match
                    ? _MatchCard(item: chats[i])
                    : _ChatTile(item: chats[i]),
              ),
            ),
          SliverToBoxAdapter(child: _archived()),
        ],
      ),
    );
  }

  // ── Encabezado
  Widget _header() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Row(
          children: [
            const Text('Mensajes',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: C.text,
                    letterSpacing: -0.3)),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: C.primary, borderRadius: BorderRadius.circular(20)),
              child: const Text('3 no leídos',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
            const Spacer(),
            Material(
              color: C.primarySoft,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {},
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  child: Row(children: [
                    Icon(Icons.person_add_alt_1_rounded,
                        size: 16, color: C.primary),
                    SizedBox(width: 6),
                    Text('Nuevo',
                        style: TextStyle(
                            color: C.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                  ]),
                ),
              ),
            ),
          ],
        ),
      );

  // ── Buscador
  Widget _searchBar() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          controller: _search,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(color: C.text, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Buscar dúos, squads o juegos...',
            hintStyle: const TextStyle(color: C.muted, fontSize: 14),
            prefixIcon: const Icon(Icons.search_rounded, color: C.muted),
            suffixIcon: const Icon(Icons.mic_none_rounded, color: C.muted),
            filled: true,
            fillColor: C.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: C.border)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: C.primary)),
          ),
        ),
      );

  // ── Filtros
  Widget _filterChips() => SizedBox(
        height: 52,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          scrollDirection: Axis.horizontal,
          itemCount: _filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final selected = i == _filter;
            final n = _count(i);
            return GestureDetector(
              onTap: () => setState(() => _filter = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: selected ? C.primary : C.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: selected ? C.primary : C.border),
                ),
                alignment: Alignment.center,
                child: Row(children: [
                  Text(_filters[i],
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : C.muted)),
                  if (n > 0) ...[
                    const SizedBox(width: 6),
                    Text('$n',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: selected ? Colors.white70 : C.primary)),
                  ],
                ]),
              ),
            );
          },
        ),
      );

  // ── Dúos en línea
  Widget _onlineSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
            child: Row(children: [
              const Icon(Icons.circle, size: 8, color: C.online),
              const SizedBox(width: 6),
              const Text('Dúos en línea ahora',
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: C.text)),
              const Spacer(),
              Text('${_onlineDuos.length} conectados',
                  style: const TextStyle(fontSize: 11, color: C.online)),
            ]),
          ),
          SizedBox(
            height: 92,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _onlineDuos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (_, i) {
                final d = _onlineDuos[i];
                return SizedBox(
                  width: 62,
                  child: Column(children: [
                    Avatar(name: d.$1, size: 54, online: true, c1: d.$3),
                    const SizedBox(height: 6),
                    Text(d.$1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: C.text)),
                    Text(d.$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 9.5, color: C.muted)),
                  ]),
                );
              },
            ),
          ),
        ],
      );

  Widget _inboxTitle() => const Padding(
        padding: EdgeInsets.fromLTRB(16, 18, 16, 10),
        child: Row(children: [
          Text('Bandeja de entrada',
              style: TextStyle(
                  fontSize: 12.5, fontWeight: FontWeight.w700, color: C.muted)),
          Spacer(),
          Text('Filtrado por actividad',
              style: TextStyle(fontSize: 11, color: C.primary)),
        ]),
      );

  Widget _archived() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.archive_outlined, size: 16, color: C.muted),
          label: const Text('Ver chats archivados (3)',
              style: TextStyle(color: C.muted, fontSize: 12)),
        ),
      );
}

/// ───────────────────────── Widgets ─────────────────────────
class _PillChip extends StatelessWidget {
  final Pill pill;
  const _PillChip(this.pill);

  @override
  Widget build(BuildContext context) {
    final highlighted = pill.color != C.muted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: highlighted ? pill.color.withAlpha(38) : C.surfaceHi,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(pill.label,
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: pill.color)),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final ChatItem item;
  const _ChatTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final unread = item.unread > 0;
    return Material(
      color: C.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: unread ? C.primary.withAlpha(128) : C.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Avatar(
                  name: item.name,
                  online: item.online,
                  c1: item.c1,
                  c2: item.c2),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Flexible(
                        child: Text(item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: C.text)),
                      ),
                      if (item.verified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_rounded,
                            size: 14, color: C.primary),
                      ],
                      const SizedBox(width: 8),
                      Text(item.time,
                          style: TextStyle(
                              fontSize: 11,
                              color: unread ? C.primary : C.muted)),
                    ]),
                    if (item.pills.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: item.pills.map(_PillChip.new).toList()),
                    ],
                    const SizedBox(height: 7),
                    Row(children: [
                      Expanded(
                        child: Text(item.preview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 12.5,
                                color: unread ? C.text : C.muted)),
                      ),
                      if (unread)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          width: 20,
                          height: 20,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                              color: C.primary, shape: BoxShape.circle),
                          child: Text('${item.unread}',
                              style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                        ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tarjeta especial para un nuevo "match" con botón de saludo.
class _MatchCard extends StatelessWidget {
  final ChatItem item;
  const _MatchCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final first = item.name.split(' ').first;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1740), C.surface]),
        border: Border.all(color: C.primary.withAlpha(153)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Avatar(
                name: item.name,
                size: 44,
                online: item.online,
                c1: item.c1,
                c2: item.c2),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(item.name,
                        style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: C.text)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: C.primary,
                          borderRadius: BorderRadius.circular(6)),
                      child: const Text('¡Nuevo dúo match!',
                          style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                    ),
                  ]),
                  const SizedBox(height: 5),
                  Wrap(
                      spacing: 6,
                      children: item.pills.map(_PillChip.new).toList()),
                ],
              ),
            ),
            Text(item.time,
                style: const TextStyle(fontSize: 11, color: C.muted)),
          ]),
          const SizedBox(height: 10),
          Text(item.preview,
              style: const TextStyle(fontSize: 12.5, color: C.text)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: C.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                ),
                icon: const Icon(Icons.waving_hand_rounded, size: 16),
                label: Text('Saludar a $first',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: C.border),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              ),
              child: const Icon(Icons.event_available_rounded,
                  size: 18, color: C.muted),
            ),
          ]),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40, horizontal: 32),
      child: Column(children: [
        Icon(Icons.forum_outlined, size: 40, color: C.muted),
        SizedBox(height: 12),
        Text('No hay chats con ese filtro',
            style: TextStyle(
                color: C.text, fontWeight: FontWeight.w700, fontSize: 14)),
        SizedBox(height: 4),
        Text('Prueba con otra búsqueda o toca Nuevo para empezar un chat.',
            textAlign: TextAlign.center,
            style: TextStyle(color: C.muted, fontSize: 12)),
      ]),
    );
  }
}
