import 'package:flutter/material.dart';

enum IssuePriority {
  low,
  medium,
  high,
  critical,
}

class PriorityBadge extends StatelessWidget {
  final IssuePriority priority;
  final double fontSize;
  final bool showIcon;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.fontSize = 12,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getPriorityConfig(priority);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: config.color.withOpacity(0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              config.icon,
              size: 14,
              color: config.color,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            config.label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: config.color,
            ),
          ),
        ],
      ),
    );
  }

  _PriorityConfig _getPriorityConfig(IssuePriority priority) {
    switch (priority) {
      case IssuePriority.low:
        return _PriorityConfig(
          label: "Low",
          color: Colors.green,
          icon: Icons.arrow_downward,
        );
      case IssuePriority.medium:
        return _PriorityConfig(
          label: "Medium",
          color: Colors.orange,
          icon: Icons.remove,
        );
      case IssuePriority.high:
        return _PriorityConfig(
          label: "High",
          color: Colors.deepOrange,
          icon: Icons.arrow_upward,
        );
      case IssuePriority.critical:
        return _PriorityConfig(
          label: "Critical",
          color: Colors.red,
          icon: Icons.priority_high,
        );
    }
  }
}

class _PriorityConfig {
  final String label;
  final Color color;
  final IconData icon;

  _PriorityConfig({
    required this.label,
    required this.color,
    required this.icon,
  });
}
