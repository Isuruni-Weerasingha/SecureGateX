enum ActivityType {
  unlock,
  lock,
  guest,
  failed,
}

class ActivityLogModel {
  final String id;
  final ActivityType type;
  final String action;
  final String user;
  final DateTime timestamp;
  final String? method;

  ActivityLogModel({
    required this.id,
    required this.type,
    required this.action,
    required this.user,
    required this.timestamp,
    this.method,
  });

  String getRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

