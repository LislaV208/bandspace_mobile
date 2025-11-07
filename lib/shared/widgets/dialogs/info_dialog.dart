import 'package:flutter/material.dart';

class InfoDialog extends StatelessWidget {
  final String title;
  final String message;

  const InfoDialog({super.key, required this.title, required this.message});

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => InfoDialog(
        title: title,
        message: message,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Text(message),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            'OK',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
