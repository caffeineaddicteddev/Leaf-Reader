import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router.dart';

class LeafBottomNav extends StatelessWidget {
  const LeafBottomNav({required this.currentIndex, super.key});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (int selectedIndex) {
        if (selectedIndex == 0 && currentIndex != 0) {
          context.go(
            AppRoutes.library,
            extra: AppNavigationDirection.backward,
          );
        } else if (selectedIndex == 1 && currentIndex != 1) {
          context.go(
            AppRoutes.settings,
            extra: AppNavigationDirection.forward,
          );
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
