import 'package:flutter/material.dart';

class TimeSelector extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;
  final bool isEnabled;

  const TimeSelector({
    super.key,
    required this.label,
    required this.time,
    required this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  isEnabled ? const Color(0xFFE0E0E0) : const Color(0xFFF0F0F0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isEnabled
                      ? const Color(0xFF8B5B5C)
                      : const Color(0xFFBDBDBD),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    time.format(context),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isEnabled
                          ? const Color(0xFF191010)
                          : const Color(0xFFBDBDBD),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: isEnabled
                        ? const Color(0xFF8B5B5C)
                        : const Color(0xFFBDBDBD),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShopStatusToggle extends StatelessWidget {
  final bool isOpen;
  final ValueChanged<bool> onChanged;
  final bool isEnabled;

  const ShopStatusToggle({
    super.key,
    required this.isOpen,
    required this.onChanged,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Shop Status',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF191010),
          ),
        ),
        Switch(
          value: isOpen,
          onChanged: isEnabled ? onChanged : null,
          activeColor: const Color(0xFFE9B8BA),
        ),
      ],
    );
  }
}
