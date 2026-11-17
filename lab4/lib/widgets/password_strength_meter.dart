import 'package:flutter/material.dart';

import '../utils/validators.dart';

/// Live strength bar for a password being typed (task 2 #4).
class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          final strength = passwordStrength(value.text);
          final scheme = Theme.of(context).colorScheme;
          final (label, color, fraction) = switch (strength) {
            PasswordStrength.none => ('', scheme.outline, 0.0),
            PasswordStrength.weak => ('Сул', scheme.error, 1 / 3),
            PasswordStrength.medium => (
              'Дундаж',
              Colors.orange.shade700,
              2 / 3,
            ),
            PasswordStrength.strong => ('Хүчтэй', Colors.green.shade600, 1.0),
          };
          return Semantics(
            label: label.isEmpty ? 'Нууц үгийн хүч' : 'Нууц үгийн хүч: $label',
            excludeSemantics: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 6,
                    color: color,
                    backgroundColor: scheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label.isEmpty ? 'Нууц үгийн хүч' : 'Нууц үгийн хүч: $label',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: label.isEmpty ? scheme.onSurfaceVariant : color,
                  ),
                ),
              ],
            ),
          );
        },
      );
}
