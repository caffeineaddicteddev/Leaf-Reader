import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router.dart';

class LeafBottomNav extends StatelessWidget {
  const LeafBottomNav({required this.index, super.key});

  final int index;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Design Colors adapted to current theme
    final Color surface = colorScheme.surface;
    final Color onSurfaceVariant = colorScheme.onSurfaceVariant;
    final Color primary = colorScheme.primary;
    final Color surfaceContainerHighest = isDark ? colorScheme.surfaceContainerHighest : const Color(0xFFDEE2EC);
    final Color outlineVariant = colorScheme.outlineVariant;

    return Container(
      decoration: BoxDecoration(
        color: surface.withOpacity(0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(color: outlineVariant.withOpacity(0.2), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF2E333A)).withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 12, 32, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.description_outlined,
                  label: 'Library',
                  isSelected: index == 0,
                  onTap: () => context.go(AppRoutes.library),
                  primary: primary,
                  onSurfaceVariant: onSurfaceVariant,
                  surfaceContainerHighest: surfaceContainerHighest,
                ),
                _buildNavItem(
                  context,
                  icon: index == 1 ? Icons.settings : Icons.settings_outlined,
                  label: 'Settings',
                  isSelected: index == 1,
                  onTap: () => context.go(AppRoutes.settings),
                  primary: primary,
                  onSurfaceVariant: onSurfaceVariant,
                  surfaceContainerHighest: surfaceContainerHighest,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primary,
    required Color onSurfaceVariant,
    required Color surfaceContainerHighest,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? surfaceContainerHighest : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? primary : onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isSelected ? primary : onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
