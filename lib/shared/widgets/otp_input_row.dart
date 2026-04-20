import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

/// A row of 4 OTP digit boxes with full UX:
/// - Forward focus on digit entry
/// - Backward focus + clear on backspace from an empty box
/// - Tap-to-select so the existing digit is replaced immediately
/// - Paste: distributes a multi-digit string across boxes
class OtpInputRow extends StatefulWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;

  const OtpInputRow({
    super.key,
    required this.controllers,
    required this.focusNodes,
  }) : assert(controllers.length == 4 && focusNodes.length == 4);

  @override
  State<OtpInputRow> createState() => _OtpInputRowState();
}

class _OtpInputRowState extends State<OtpInputRow> {
  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.focusNodes.length; i++) {
      final index = i;
      widget.focusNodes[i].onKeyEvent = (node, event) {
        // Backspace on an empty box → clear previous box and move focus back
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            widget.controllers[index].text.isEmpty &&
            index > 0) {
          widget.controllers[index - 1].clear();
          widget.focusNodes[index - 1].requestFocus();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      };
    }
  }

  void _onChanged(String value, int index) {
    // Strip non-digits (handles some keyboard edge cases)
    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty) {
      // Field was cleared — keep focus here; backspace key handles moving back
      if (widget.controllers[index].text.isNotEmpty) {
        widget.controllers[index].clear();
      }
      return;
    }

    if (digits.length > 1) {
      // Paste: distribute across boxes starting from this index
      for (int j = 0; j < digits.length && (index + j) < 4; j++) {
        widget.controllers[index + j].text = digits[j];
      }
      final nextFocus = (index + digits.length).clamp(0, 3);
      widget.focusNodes[nextFocus].requestFocus();
      return;
    }

    // Normal single digit — advance to next box
    widget.controllers[index].text = digits;
    widget.controllers[index].selection = TextSelection.fromPosition(
      TextPosition(offset: widget.controllers[index].text.length),
    );
    if (index < 3) {
      widget.focusNodes[index + 1].requestFocus();
    } else {
      widget.focusNodes[index].unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(4, (index) {
        return SizedBox(
          width: 64,
          height: 64,
          child: TextField(
            controller: widget.controllers[index],
            focusNode: widget.focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 1,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: AppColors.backgroundLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            // Select all text on tap so the existing digit is replaced immediately
            onTap: () {
              widget.controllers[index].selection = TextSelection(
                baseOffset: 0,
                extentOffset: widget.controllers[index].text.length,
              );
            },
            onChanged: (value) => _onChanged(value, index),
          ),
        );
      }),
    );
  }
}
