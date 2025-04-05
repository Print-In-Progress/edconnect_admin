import 'package:flutter/material.dart';

class LoadingProgress extends StatelessWidget {
  final String message;
  final double? progress;
  final List<String>? steps;
  final int currentStep;

  const LoadingProgress({
    super.key,
    required this.message,
    this.progress,
    this.steps,
    this.currentStep = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        if (progress != null) ...[
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 8),
        ],
        if (steps != null) ...[
          for (var i = 0; i < steps!.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (i < currentStep)
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 16)
                  else if (i == currentStep)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    const Icon(Icons.circle_outlined, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    steps![i],
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
