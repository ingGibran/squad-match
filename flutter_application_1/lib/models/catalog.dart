import 'package:flutter/material.dart';
import '../theme.dart';

/// Listas fijas que se usan en el registro y en el perfil.
/// Si más adelante vienen de tu backend, solo cambia este archivo.

class GameInfo {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final String mode;
  const GameInfo(this.id, this.title, this.icon, this.color, this.mode);
}

const kGames = <GameInfo>[
  GameInfo('valorant', 'Valorant', Icons.gps_fixed_rounded, Color(0xFFFF4655),
      'Competitivo'),
  GameInfo('overwatch2', 'Overwatch 2', Icons.healing_rounded,
      Color(0xFFFF9C1A), 'Competitivo'),
  GameInfo('apex', 'Apex Legends', Icons.flight_takeoff_rounded,
      Color(0xFF4BB8FF), 'Competitivo'),
  GameInfo('cs2', 'Counter-Strike 2', Icons.my_location_rounded,
      Color(0xFFFFC24B), 'Competitivo'),
  GameInfo('lol', 'League of Legends', Icons.shield_rounded,
      Color(0xFF3DD6D0), 'Competitivo'),
  GameInfo('fortnite', 'Fortnite', Icons.rocket_launch_rounded,
      Color(0xFFB07BFF), 'Battle Royale'),
  GameInfo('helldivers2', 'Helldivers 2', Icons.public_rounded,
      Color(0xFFFFC24B), 'Cooperativo'),
  GameInfo('bg3', 'Baldur\'s Gate 3', Icons.auto_fix_high_rounded,
      Color(0xFFB07BFF), 'Cooperativo'),
  GameInfo('lethal', 'Lethal Company', Icons.flashlight_on_rounded, C.muted,
      'Casual'),
  GameInfo('rocketleague', 'Rocket League', Icons.sports_soccer_rounded,
      Color(0xFF4BB8FF), 'Competitivo'),
];

GameInfo gameById(String id) =>
    kGames.firstWhere((g) => g.id == id, orElse: () => kGames.first);

class PlatformInfo {
  final String id;
  final String label;
  final IconData icon;
  const PlatformInfo(this.id, this.label, this.icon);
}

const kPlatforms = <PlatformInfo>[
  PlatformInfo('pc', 'PC', Icons.desktop_windows_outlined),
  PlatformInfo('playstation', 'PlayStation', Icons.sports_esports_outlined),
  PlatformInfo('xbox', 'Xbox', Icons.gamepad_outlined),
  PlatformInfo('switch', 'Nintendo Switch', Icons.videogame_asset_outlined),
  PlatformInfo('mobile', 'Móvil', Icons.smartphone_rounded),
];

PlatformInfo platformById(String id) =>
    kPlatforms.firstWhere((p) => p.id == id, orElse: () => kPlatforms.first);

const kRanks = <String>[
  'Sin rango',
  'Hierro',
  'Bronce',
  'Plata',
  'Oro',
  'Platino',
  'Diamante',
  'Inmortal',
];

const kRegions = <String>[
  'México',
  'Centroamérica',
  'Colombia / Venezuela',
  'Perú / Ecuador',
  'Chile',
  'Argentina / Uruguay',
  'España',
  'Resto de Europa',
  'Norteamérica',
  'Otra región',
];

const kDays = <String>['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

/// Pares de colores para el avatar (el usuario elige uno por índice).
const kAvatarPalette = <(Color, Color)>[
  (Color(0xFF7B6CFF), Color(0xFF2A1B78)),
  (Color(0xFF3DD6D0), Color(0xFF1B3A5B)),
  (Color(0xFFFF5A5F), Color(0xFF5B1B3A)),
  (Color(0xFFFFC24B), Color(0xFF4A3A12)),
  (Color(0xFF3DDC84), Color(0xFF0E3A2A)),
  (Color(0xFFFF5AA5), Color(0xFF3A1B5B)),
];
