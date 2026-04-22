import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/back_button_custom.dart';
import '../services/activity_service.dart';
import '../models/activity_log_model.dart';
import 'package:intl/intl.dart';

/// Activity log screen showing all access history
class ActivityLogScreen extends StatefulWidget {
  final VoidCallback onBack;

  const ActivityLogScreen({
    super.key,
    required this.onBack,
  });

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  final _activityService = ActivityService();
  List<ActivityLogModel> _activities = [];
  Map<String, int> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final activities = await _activityService.getActivities();
    final stats = await _activityService.getActivityStats();
    setState(() {
      _activities = activities;
      _stats = stats;
      _isLoading = false;
    });
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.unlock:
        return Icons.lock_open;
      case ActivityType.lock:
        return Icons.lock;
      case ActivityType.guest:
        return Icons.person_add;
      case ActivityType.failed:
        return Icons.error_outline;
    }
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.unlock:
        return AppColors.green;
      case ActivityType.lock:
        return AppColors.blue;
      case ActivityType.guest:
        return AppColors.cyan;
      case ActivityType.failed:
        return AppColors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacingMD),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppConstants.maxMobileWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      BackButtonCustom(onPressed: widget.onBack),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Activity Log',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Complete access history',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textCyanLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Stats Summary
                  Row(
                    children: [
                      Expanded(
                        child: GlassCard(
                          padding: const EdgeInsets.all(16),
                          borderColor: AppColors.green.withOpacity(0.3),
                          backgroundColor: AppColors.green.withOpacity(0.1),
                          child: Column(
                            children: [
                              Text(
                                '${_stats['unlocks'] ?? 0}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  color: AppColors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Unlocks',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.green.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlassCard(
                          padding: const EdgeInsets.all(16),
                          borderColor: AppColors.blue.withOpacity(0.3),
                          backgroundColor: AppColors.blue.withOpacity(0.1),
                          child: Column(
                            children: [
                              Text(
                                '${_stats['locks'] ?? 0}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  color: AppColors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Locks',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.blue.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlassCard(
                          padding: const EdgeInsets.all(16),
                          borderColor: AppColors.red.withOpacity(0.3),
                          backgroundColor: AppColors.red.withOpacity(0.1),
                          child: Column(
                            children: [
                              Text(
                                '${_stats['failed'] ?? 0}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  color: AppColors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Failed',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.red.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Activity List
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.cyan),
                        ),
                      ),
                    )
                  else
                    ..._activities.map((activity) {
                      final icon = _getActivityIcon(activity.type);
                      final color = _getActivityColor(activity.type);
                      final dateFormat = DateFormat('MMM d, yyyy');
                      final timeFormat = DateFormat('h:mm a');

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: color.withOpacity(0.3),
                                  ),
                                ),
                                child: Icon(
                                  icon,
                                  size: 24,
                                  color: color,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      activity.action,
                                      style: TextStyle(
                                        color: color,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      activity.user,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Method: ${activity.method}',
                                      style: TextStyle(
                                        color: AppColors.textCyanLight,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 12,
                                          color: AppColors.textCyanLighter,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          dateFormat.format(activity.timestamp),
                                          style: TextStyle(
                                            color: AppColors.textCyanLighter,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Icon(
                                          Icons.access_time,
                                          size: 12,
                                          color: AppColors.textCyanLighter,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          timeFormat.format(activity.timestamp),
                                          style: TextStyle(
                                            color: AppColors.textCyanLighter,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 32),
                    // Next button to continue flow
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('guest-access');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cyan,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

