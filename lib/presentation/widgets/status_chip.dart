import 'package:flutter/material.dart';

enum IssueStatus {
  newIssue,
  inProgress,
  resolved,
  closed,
  waitingForClient,
}

class StatusChip extends StatelessWidget {
  final IssueStatus status;
  final double fontSize;
  final bool showIcon;

  const StatusChip({
    super.key,
    required this.status,
    this.fontSize = 12,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: config.color.withOpacity(0.4)),
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
              color: config.color,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(IssueStatus status) {
    switch (status) {
      case IssueStatus.newIssue:
        return _StatusConfig(
          label: "New",
          color: Colors.blue,
          icon: Icons.fiber_new,
        );
      case IssueStatus.inProgress:
        return _StatusConfig(
          label: "In Progress",
          color: Colors.orange,
          icon: Icons.autorenew,
        );
      case IssueStatus.resolved:
        return _StatusConfig(
          label: "Resolved",
          color: Colors.green,
          icon: Icons.check_circle,
        );
      case IssueStatus.closed:
        return _StatusConfig(
          label: "Closed",
          color: Colors.grey,
          icon: Icons.lock,
        );
      case IssueStatus.waitingForClient:
        return _StatusConfig(
          label: "Waiting",
          color: Colors.purple,
          icon: Icons.hourglass_bottom,
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final Color color;
  final IconData icon;

  _StatusConfig({
    required this.label,
    required this.color,
    required this.icon,
  });
}
