import 'package:flutter/material.dart';

class CallButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;

  const CallButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? theme.colorScheme.secondaryContainer,
          foregroundColor: textColor ?? theme.colorScheme.onSecondaryContainer,
          textStyle: theme.textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
