import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyState({super.key, required this.icon, required this.title, this.subtitle, this.action});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 180),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.textFaint),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 18, color: AppColors.textFaint)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: const TextStyle(fontSize: 13, color: AppColors.textFaint)),
          ],
          if (action != null) ...[
            const SizedBox(height: 16),
            action!,
          ],
        ],
      ),
    );
  }
}
