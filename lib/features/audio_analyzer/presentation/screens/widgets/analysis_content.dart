import 'package:flutter/material.dart';
import 'package:markdown_widget/widget/all.dart';
import 'package:vocario/features/audio_analyzer/domain/entities/audio_analysis.dart';

class AnalysisContent extends StatelessWidget {
  final AudioAnalysis analysis;

  const AnalysisContent({
    super.key,
    required this.analysis,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 16),
              const SizedBox(width: 4),
              Text(
                'Analysis Complete',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (analysis.content.isNotEmpty)
          SizedBox(
            width: double.infinity,
            child: MarkdownBlock(data: analysis.content),
          ),
      ],
    );
  }
}