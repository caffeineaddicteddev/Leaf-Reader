import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router.dart';

class LeafBottomNav extends StatelessWidget {
  const LeafBottomNav({required this.index, super.key});

  final int index;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: NavigationBar(
        selectedIndex: index,
        height: 76,
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: const Color(0xFFDCE6F6),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        onDestinationSelected: (int value) {
          if (value == 0) {
            context.go(AppRoutes.library);
          } else {
            context.go(AppRoutes.settings);
          }
        },
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description_rounded),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
