import '../models/activity_log_model.dart';

class ActivityService {
  final List<ActivityLogModel> _activities = [
    ActivityLogModel(
      id: '1',
      type: ActivityType.unlock,
      action: 'Door Unlocked',
      user: 'John Doe',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      method: 'Fingerprint',
    ),
    ActivityLogModel(
      id: '2',
      type: ActivityType.lock,
      action: 'Door Locked',
      user: 'John Doe',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      method: 'App',
    ),
    ActivityLogModel(
      id: '3',
      type: ActivityType.guest,
      action: 'Guest Access Granted',
      user: 'Guest User',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      method: 'QR Code',
    ),
  ];

  Future<List<ActivityLogModel>> getRecentActivities(int limit) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _activities.take(limit).toList();
  }

  Future<List<ActivityLogModel>> getAllActivities() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _activities;
  }

  Future<List<ActivityLogModel>> getActivities() async {
    return getAllActivities();
  }

  Future<Map<String, int>> getActivityStats() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'total': _activities.length,
      'unlock': _activities.where((a) => a.type == ActivityType.unlock).length,
      'lock': _activities.where((a) => a.type == ActivityType.lock).length,
      'guest': _activities.where((a) => a.type == ActivityType.guest).length,
      'failed': _activities.where((a) => a.type == ActivityType.failed).length,
    };
  }
}

