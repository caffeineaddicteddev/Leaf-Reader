import 'package:flutter/material.dart';

import '../../domain/language_registry.dart';

class LanguageDropdown extends StatelessWidget {
  const LanguageDropdown({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: LanguageRegistry.languages
          .map(
            (language) => DropdownMenuItem<String>(
              value: language.code,
              child: Text(language.displayName),
            ),
          )
          .toList(growable: false),
      onChanged: onChanged,
    );
  }
}
