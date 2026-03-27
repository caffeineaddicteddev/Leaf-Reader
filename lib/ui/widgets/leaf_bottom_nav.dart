import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router.dart';

class LeafBottomNav extends StatelessWidget {
  const LeafBottomNav({required this.index, super.key});

  final int index;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: NavigationBar(
            selectedIndex: index,
            backgroundColor: Colors.transparent,
            indicatorColor: const Color(0xFFDCE6F6),
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
        ),
      ),
    );
  }
}
