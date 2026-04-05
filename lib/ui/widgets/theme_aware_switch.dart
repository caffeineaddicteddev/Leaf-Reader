import 'package:flutter/material.dart';

class ThemeAwareSwitch extends StatelessWidget {
  const ThemeAwareSwitch({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color activeThumbColor = colorScheme.primary;
    final Color activeTrackColor = colorScheme.primary.withValues(alpha: 0.42);
    final Color inactiveThumbColor =
        isDarkMode ? const Color(0xFF5B5B66) : const Color(0xFFFDFDFE);
    final Color inactiveTrackColor =
        isDarkMode ? const Color(0xFF3A3A44) : const Color(0xFFD8DDE8);
    final Color inactiveOutlineColor =
        isDarkMode ? const Color(0xFFE6E6EA) : const Color(0xFF2F3440);

    return Switch(
      value: value,
      onChanged: onChanged,
      activeThumbColor: activeThumbColor,
      activeTrackColor: activeTrackColor,
      inactiveThumbColor: inactiveThumbColor,
      inactiveTrackColor: inactiveTrackColor,
      trackOutlineWidth: const WidgetStatePropertyAll<double>(2),
      trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return activeThumbColor.withValues(alpha: 0.2);
          }
          return inactiveOutlineColor;
        },
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
