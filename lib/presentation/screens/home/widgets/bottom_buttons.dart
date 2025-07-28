import 'package:flutter/material.dart';

class BottomButtons extends StatelessWidget {
  final String importAudioText;
  final String importVideoText;
  final TextStyle? textStyle;
  
  const BottomButtons({
    super.key,
    required this.importAudioText,
    required this.importVideoText,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Import Audio feature coming soon!'),
                ),
              );
            },
            icon: const Icon(Icons.upload_file),
            label: Text(
              importAudioText,
              style: textStyle,
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Import Video feature coming soon!'),
                ),
              );
            },
            icon: const Icon(Icons.video_library),
            label: Text(
              importVideoText,
              style: textStyle,
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}