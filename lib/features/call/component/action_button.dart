import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final Color textColor;
  final VoidCallback? onPressed;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    required this.textColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;

    return Column(
      children: [
        FloatingActionButton(
          heroTag: label,
          onPressed: onPressed,
          backgroundColor: isDisabled ? Colors.grey : color,
          foregroundColor: iconColor,
          elevation: 4,
          child: Icon(icon),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: textColor),
        ),
      ],
    );
  }
}
