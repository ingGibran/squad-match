import 'catalog.dart';

/// Un juego del usuario con su rango.
class GameEntry {
  final String gameId;
  final String rank;
  const GameEntry(this.gameId, this.rank);

  Map<String, dynamic> toJson() => {'gameId': gameId, 'rank': rank};

  factory GameEntry.fromJson(Map<String, dynamic> j) =>
      GameEntry(j['gameId'] as String, j['rank'] as String);
}

String formatMinutes(int m) =>
    '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';

/// Datos públicos del usuario. Es lo que muestra la pestaña Perfil.
/// La contraseña NUNCA vive aquí: la maneja el repositorio de autenticación.
class UserProfile {
  final String id;
  final String email;
  final String displayName;
  final String username; // sin la @
  final String bio;
  final String gamerTag; // ID de juego, ej. novarogue#0001
  final List<String> platforms; // ids de kPlatforms
  final List<GameEntry> games;
  final String region;
  final List<int> days; // 0 = Lun ... 6 = Dom
  final int startMinutes;
  final int endMinutes;
  final int avatarColor; // índice en kAvatarPalette
  final int duoGames;
  final bool verified;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.username,
    this.bio = '',
    this.gamerTag = '',
    this.platforms = const [],
    this.games = const [],
    this.region = '',
    this.days = const [0, 1, 2, 3, 4, 5, 6],
    this.startMinutes = 21 * 60,
    this.endMinutes = 60,
    this.avatarColor = 0,
    this.duoGames = 0,
    this.verified = false,
    required this.createdAt,
  });

  UserProfile copyWith({
    String? id,
    String? displayName,
    String? bio,
    String? gamerTag,
    int? avatarColor,
    DateTime? createdAt,
  }) =>
      UserProfile(
        id: id ?? this.id,
        email: email,
        displayName: displayName ?? this.displayName,
        username: username,
        bio: bio ?? this.bio,
        gamerTag: gamerTag ?? this.gamerTag,
        platforms: platforms,
        games: games,
        region: region,
        days: days,
        startMinutes: startMinutes,
        endMinutes: endMinutes,
        avatarColor: avatarColor ?? this.avatarColor,
        duoGames: duoGames,
        verified: verified,
        createdAt: createdAt ?? this.createdAt,
      );

  /// Ej.: "Lun-Dom 21:00 a 01:00" o "Lun, Mié, Vie 20:00 a 23:30".
  String get scheduleLabel {
    final d = [...days]..sort();
    final String dayText;
    if (d.isEmpty) {
      dayText = 'Sin días definidos';
    } else if (d.length == 7) {
      dayText = 'Lun-Dom';
    } else if (d.length >= 3 && d.last - d.first + 1 == d.length) {
      dayText = '${kDays[d.first]}-${kDays[d.last]}';
    } else {
      dayText = d.map((i) => kDays[i]).join(', ');
    }
    return '$dayText ${formatMinutes(startMinutes)} a ${formatMinutes(endMinutes)}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'username': username,
        'bio': bio,
        'gamerTag': gamerTag,
        'platforms': platforms,
        'games': games.map((g) => g.toJson()).toList(),
        'region': region,
        'days': days,
        'startMinutes': startMinutes,
        'endMinutes': endMinutes,
        'avatarColor': avatarColor,
        'duoGames': duoGames,
        'verified': verified,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        id: j['id'] as String,
        email: j['email'] as String,
        displayName: j['displayName'] as String,
        username: j['username'] as String,
        bio: (j['bio'] as String?) ?? '',
        gamerTag: (j['gamerTag'] as String?) ?? '',
        platforms: ((j['platforms'] as List?) ?? const []).cast<String>(),
        games: ((j['games'] as List?) ?? const [])
            .map((e) => GameEntry.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        region: (j['region'] as String?) ?? '',
        days: ((j['days'] as List?) ?? const [0, 1, 2, 3, 4, 5, 6]).cast<int>(),
        startMinutes: (j['startMinutes'] as int?) ?? 21 * 60,
        endMinutes: (j['endMinutes'] as int?) ?? 60,
        avatarColor: (j['avatarColor'] as int?) ?? 0,
        duoGames: (j['duoGames'] as int?) ?? 0,
        verified: (j['verified'] as bool?) ?? false,
        createdAt: DateTime.parse(j['createdAt'] as String),
      );
}
