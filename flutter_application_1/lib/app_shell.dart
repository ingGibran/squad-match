import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/messages_screen.dart';
import 'screens/placeholder_screen.dart';
import 'screens/profile_screen.dart';

/// Contenedor principal: muestra la pestaña activa y la barra inferior.
/// Usa IndexedStack para que cada pestaña conserve su estado
/// (scroll, filtros, texto del buscador...) al cambiar entre ellas.
class AppShell extends StatefulWidget {
  /// 0 = Clips, 1 = Descubrir, 2 = Mensajes, 3 = Perfil
  final int initialIndex;

  const AppShell({super.key, this.initialIndex = 0});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}

class _AppShellState extends State<AppShell> {
  late int _index = widget.initialIndex;

  // Cuando tengas backend, este número vendrá de tus datos.
  static const _unreadMessages = 3;
  static const _messagesTab = 2;

  static const _items = [
    _NavItem(Icons.movie_outlined, Icons.movie_rounded, 'Clips'),
    _NavItem(Icons.explore_outlined, Icons.explore_rounded, 'Descubrir'),
    _NavItem(Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded,
        'Mensajes'),
    _NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Perfil'),
  ];

  static const _screens = <Widget>[
    ClipsScreen(),
    DiscoverScreen(),
    MessagesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: _bottomNav(),
    );
  }

  Widget _bottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: C.surface,
        border: Border(top: BorderSide(color: C.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final selected = i == _index;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (i != _index) setState(() => _index = i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? C.primarySoft : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Badge(
                      isLabelVisible: i == _messagesTab && _unreadMessages > 0,
                      label: Text('$_unreadMessages'),
                      backgroundColor: C.primary,
                      child: Icon(
                        selected ? item.activeIcon : item.icon,
                        size: 22,
                        color: selected ? C.primary : C.muted,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(item.label,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: selected ? C.primary : C.muted)),
                  ]),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
