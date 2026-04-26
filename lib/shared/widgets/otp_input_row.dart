import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

/// A row of 4 OTP digit boxes with full UX:
/// - Forward focus on digit entry
/// - Backward focus + clear on backspace from an empty box
/// - Tap-to-select so the existing digit is replaced immediately
/// - Paste / multi-digit: distributes across all boxes
/// - Clipboard auto-fill: when first box gains focus and all are empty,
///   automatically reads clipboard and fills if it contains 4 digits
/// - autofillHints(oneTimeCode): iOS shows SMS OTP in keyboard toolbar;
///   Android autofill framework offers the code from Messages
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

    // Backspace navigation: empty box + backspace → clear previous, move back
    for (int i = 0; i < widget.focusNodes.length; i++) {
      final index = i;
      widget.focusNodes[i].onKeyEvent = (node, event) {
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

    // Clipboard: when first box gains focus with all boxes empty, auto-fill
    widget.focusNodes[0].addListener(_onFirstBoxFocus);
  }

  @override
  void dispose() {
    widget.focusNodes[0].removeListener(_onFirstBoxFocus);
    super.dispose();
  }

  void _onFirstBoxFocus() {
    if (widget.focusNodes[0].hasFocus && _allEmpty()) {
      _tryFillFromClipboard();
    }
  }

  bool _allEmpty() => widget.controllers.every((c) => c.text.isEmpty);

  /// Returns the index of the first empty box, or null if all are filled.
  /// Used to enforce left-to-right entry — taps on later boxes are
  /// redirected here so the user can't start typing from the middle.
  int? _firstEmptyIndex() {
    for (int i = 0; i < widget.controllers.length; i++) {
      if (widget.controllers[i].text.isEmpty) return i;
    }
    return null;
  }

  Future<void> _tryFillFromClipboard() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final raw = (data?.text ?? '').trim();
      final digits = raw.replaceAll(RegExp(r'\D'), '');
      if (digits.length == 4) {
        _distribute(digits, 0);
      }
    } catch (_) {
      // Clipboard access may be unavailable — fail silently
    }
  }

  /// Puts [digits] into boxes starting at [startIndex] and moves focus.
  void _distribute(String digits, int startIndex) {
    for (int j = 0; j < digits.length && (startIndex + j) < 4; j++) {
      widget.controllers[startIndex + j].text = digits[j];
    }
    final filled = startIndex + digits.length;
    if (filled >= 4) {
      // All boxes filled — dismiss keyboard
      widget.focusNodes[3].unfocus();
    } else {
      widget.focusNodes[filled.clamp(0, 3)].requestFocus();
    }
  }

  void _onChanged(String value, int index) {
    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty) {
      if (widget.controllers[index].text.isNotEmpty) {
        widget.controllers[index].clear();
      }
      return;
    }

    if (digits.length > 1) {
      // iOS autofill or paste: distribute from this box onward
      _distribute(digits, index);
      return;
    }

    // Normal single digit — advance
    widget.controllers[index].text = digits;
    widget.controllers[index].selection =
        const TextSelection.collapsed(offset: 1);
    if (index < 3) {
      widget.focusNodes[index + 1].requestFocus();
    } else {
      widget.focusNodes[index].unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    // AutofillGroup is required for autofillHints to be picked up by the OS
    return AutofillGroup(
      child: Row(
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
              // First box allows up to 4 chars so iOS autofill (which puts
              // the whole code into the focused field) triggers _onChanged
              // with all 4 digits, which _distribute then spreads out.
              // Boxes 1-3 still enforce single-digit entry.
              maxLength: index == 0 ? 4 : 1,
              // Signals OS to offer the SMS OTP above the keyboard
              autofillHints: const [AutofillHints.oneTimeCode],
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
              // Enforce left-to-right entry: tapping a box past the first
              // empty one jumps focus back to the first empty.
              // Otherwise (re-tapping a filled box at or before the first
               // empty), select the digit so the next keystroke replaces it.
              onTap: () {
                final firstEmpty = _firstEmptyIndex();
                if (firstEmpty != null && index > firstEmpty) {
                  widget.focusNodes[firstEmpty].requestFocus();
                  return;
                }
                widget.controllers[index].selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: widget.controllers[index].text.length,
                );
              },
              onChanged: (value) => _onChanged(value, index),
            ),
          );
        }),
      ),
    );
  }
}
