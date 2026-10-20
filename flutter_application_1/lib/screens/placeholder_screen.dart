// Pantallas que aún no están diseñadas en código: Clips y Descubrir.
// Reemplaza el contenido de cada clase cuando las programes.
import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../widgets.dart';

class ClipsScreen extends StatelessWidget {
  const ClipsScreen({super.key});

  @override
  Widget build(BuildContext context) => const _Placeholder(
        section: 'Clips',
        icon: Icons.movie_outlined,
        title: 'Clips',
        message: 'Aquí irá el feed vertical de clips de tus juegos.',
      );
}

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) => const _Placeholder(
        section: 'Descubrir',
        icon: Icons.explore_outlined,
        title: 'Descubrir',
        message: 'Aquí irán las tarjetas para buscar dúos y squads.',
      );
}

class _Placeholder extends StatelessWidget {
  final String section;
  final IconData icon;
  final String title;
  final String message;

  const _Placeholder({
    required this.section,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          SyncTopBar(section: section),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                          color: C.primarySoft,
                          borderRadius: BorderRadius.circular(22)),
                      child: Icon(icon, size: 34, color: C.primary),
                    ),
                    const SizedBox(height: 16),
                    Text(title,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: C.text)),
                    const SizedBox(height: 6),
                    Text(message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, color: C.muted)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
