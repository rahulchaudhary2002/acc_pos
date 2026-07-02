import 'package:flutter/material.dart';

/// Wraps [child] with a translucent spinner overlay while [isLoading] is true,
/// so async actions never leave the screen looking frozen or unresponsive.
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({super.key, required this.isLoading, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.15),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}
