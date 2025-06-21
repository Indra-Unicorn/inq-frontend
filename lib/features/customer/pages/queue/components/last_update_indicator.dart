import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../../shared/common_style.dart';
import '../../../../../shared/constants/app_colors.dart';

class LastUpdateIndicator extends StatefulWidget {
  final DateTime? lastUpdateTime;

  const LastUpdateIndicator({
    super.key,
    this.lastUpdateTime,
  });

  @override
  State<LastUpdateIndicator> createState() => _LastUpdateIndicatorState();
}

class _LastUpdateIndicatorState extends State<LastUpdateIndicator> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(LastUpdateIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lastUpdateTime != widget.lastUpdateTime) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.lastUpdateTime != null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            // Trigger rebuild to update the time display
          });
        } else {
          timer.cancel();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lastUpdateTime == null) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final difference = now.difference(widget.lastUpdateTime!);

    String timeText;
    if (difference.inSeconds < 60) {
      timeText = '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      timeText = '${difference.inMinutes}m ago';
    } else {
      timeText = '${difference.inHours}h ago';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.success.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            size: 12,
            color: AppColors.success,
          ),
          const SizedBox(width: 4),
          Text(
            'Updated $timeText',
            style: CommonStyle.caption.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
