import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router.dart';

class LeafBottomNav extends StatelessWidget {
  const LeafBottomNav({required this.index, super.key});

  final int index;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (int selectedIndex) {
        if (selectedIndex == 0 && index != 0) {
          context.go(AppRoutes.library);
        } else if (selectedIndex == 1 && index != 1) {
          context.go(AppRoutes.settings);
        }
      },
      destinations: const <NavigationDestination>[
        NavigationDestination(
          icon: Icon(Icons.library_books_outlined),
          selectedIcon: Icon(Icons.library_books),
          label: 'Library',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
