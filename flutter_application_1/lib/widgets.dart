import 'package:flutter/material.dart';
import 'theme.dart';

/// Avatar circular con degradado, iniciales y punto de "en línea".
class Avatar extends StatelessWidget {
  final String name;
  final double size;
  final bool online;
  final Color c1;
  final Color c2;

  const Avatar({
    super.key,
    required this.name,
    this.size = 48,
    this.online = false,
    this.c1 = C.primary,
    this.c2 = const Color(0xFF1B1F3A),
  });

  String get _initials {
    final cleaned = name
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ' ')
        .trim();
    if (cleaned.isEmpty) return '?';
    final parts = cleaned.split(RegExp(r'\s+'));
    String first(String s) => String.fromCharCode(s.runes.first);
    if (parts.length == 1) return first(parts.first).toUpperCase();
    return (first(parts[0]) + first(parts[1])).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [c1, c2]),
            border: Border.all(color: c1.withAlpha(180), width: 1.5),
          ),
          child: Text(_initials,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: size * 0.3)),
        ),
        if (online)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.27,
              height: size * 0.27,
              decoration: BoxDecoration(
                color: C.online,
                shape: BoxShape.circle,
                border: Border.all(color: C.surface, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

/// Barra superior con la marca "SyncPlay" y el nombre de la sección.
class SyncTopBar extends StatelessWidget {
  final String section;
  final List<Widget> actions;

  const SyncTopBar({super.key, required this.section, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                  colors: [C.primary, Color(0xFF3B2FB5)]),
            ),
            child: const Icon(Icons.bolt_rounded, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 8),
          const Text('SyncPlay',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: C.text,
                  letterSpacing: -0.2)),
          const SizedBox(width: 8),
          Text(section,
              style: const TextStyle(fontSize: 13, color: C.muted)),
          const Spacer(),
          ...actions,
        ],
      ),
    );
  }
}
