import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Qty stepper with a directly editable quantity field in the middle —
/// typing a number commits it live (same behaviour as the rate/cost inputs),
/// while +/- keep working for one-tap adjustments.
class QtyStepperField extends StatefulWidget {
  final double qty;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final ValueChanged<double> onQtyChanged;

  /// Fixed width for the text field; null lets it expand to fill the row.
  final double? fieldWidth;

  const QtyStepperField({
    super.key,
    required this.qty,
    required this.onIncrement,
    required this.onDecrement,
    required this.onQtyChanged,
    this.fieldWidth,
  });

  @override
  State<QtyStepperField> createState() => _QtyStepperFieldState();
}

class _QtyStepperFieldState extends State<QtyStepperField> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();

  static String _format(double qty) => qty.toStringAsFixed(qty.truncateToDouble() == qty ? 0 : 2);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _format(widget.qty));
    // Restore a valid value if the field is left empty/invalid on blur.
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && double.tryParse(_controller.text) != widget.qty) {
        _controller.text = _format(widget.qty);
      }
    });
  }

  @override
  void didUpdateWidget(QtyStepperField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync external changes (stepper taps) without clobbering active typing.
    if (widget.qty != double.tryParse(_controller.text)) {
      _controller.text = _format(widget.qty);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final field = SizedBox(
      width: widget.fieldWidth,
      height: 40,
      child: TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 4),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: AppColors.border, width: 1.5),
          ),
        ),
        onChanged: (value) {
          final qty = double.tryParse(value);
          if (qty != null && qty > 0) widget.onQtyChanged(qty);
        },
      ),
    );

    final stepper = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _stepperButton(Icons.remove, widget.onDecrement),
        widget.fieldWidth == null ? Expanded(child: field) : field,
        _stepperButton(Icons.add, widget.onIncrement),
      ],
    );

    // Guards against overflow on narrow screens when fieldWidth is fixed.
    return widget.fieldWidth == null ? stepper : FittedBox(fit: BoxFit.scaleDown, child: stepper);
  }

  Widget _stepperButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: AppColors.surfaceTotals, border: Border.all(color: AppColors.border)),
        child: Icon(icon, size: 16),
      ),
    );
  }
}
