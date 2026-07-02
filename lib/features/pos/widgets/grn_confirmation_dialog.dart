import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../models/transaction_result.dart';

Future<void> showGrnConfirmation(BuildContext context, TransactionResult result) {
  return showDialog(
    context: context,
    builder: (_) => Dialog(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.section),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 48),
            const SizedBox(height: AppSpacing.card),
            const Text('Purchase Recorded', style: AppTextStyles.subsectionTitle),
            const SizedBox(height: AppSpacing.field),
            Text('GRN No: ${result.documentNo}', style: AppTextStyles.helper),
            const SizedBox(height: 4),
            Text('Net Total: Rs ${result.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.section),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
