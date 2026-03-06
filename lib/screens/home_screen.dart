import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_glass_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/icon_button_custom.dart';
import '../models/door_status_model.dart';
import '../services/door_service.dart';
import '../services/activity_service.dart';
import '../models/activity_log_model.dart';

/// Home screen with door control and quick actions
class HomeScreen extends StatefulWidget {
  final String userName;
  final Function(String screen) onNavigate;

  const HomeScreen({
    super.key,
    required this.userName,
    required this.onNavigate,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _doorService = DoorService();
  final _activityService = ActivityService();
  DoorStatusModel _doorStatus = DoorStatusModel(isLocked: true);
  List<ActivityLogModel> _recentActivities = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _doorStatus = _doorService.getCurrentStatus();
    });
    final activities = await _activityService.getRecentActivities(3);
    setState(() {
      _recentActivities = activities;
    });
  }

  Future<void> _toggleDoor(bool lock) async {
    setState(() => _isLoading = true);
    
    try {
      bool success;
      if (lock) {
        success = await _doorService.lockDoor();
      } else {
        success = await _doorService.unlockDoor();
      }
      
      if (success) {
        setState(() {
          _doorStatus = _doorService.getCurrentStatus();
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome back,',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            widget.userName,
                            style: const TextStyle(
                              fontSize: 18,
                              color: AppColors.cyan,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButtonCustom(
                            icon: Icons.notifications_outlined,
                            onPressed: () => widget.onNavigate('notifications'),
                            badge: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButtonCustom(
                            icon: Icons.menu,
                            onPressed: () => widget.onNavigate('profile'),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Door Status Card
                  GradientGlassCard(
                    padding: const EdgeInsets.all(24),
                    glowColor: _doorStatus.isLocked
                        ? AppColors.red
                        : AppColors.green,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Front Door',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _doorStatus.isLocked
                                    ? AppColors.red.withOpacity(0.2)
                                    : AppColors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _doorStatus.isLocked
                                      ? AppColors.red.withOpacity(0.3)
                                      : AppColors.green.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                _doorStatus.isLocked ? 'Locked' : 'Unlocked',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _doorStatus.isLocked
                                      ? AppColors.red
                                      : AppColors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Lock Icon
                        Container(
                          width: 128,
                          height: 128,
                          decoration: BoxDecoration(
                            color: _doorStatus.isLocked
                                ? AppColors.red.withOpacity(0.1)
                                : AppColors.green.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _doorStatus.isLocked
                                  ? AppColors.red.withOpacity(0.3)
                                  : AppColors.green.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            _doorStatus.isLocked
                                ? Icons.lock
                                : Icons.lock_open,
                            size: 64,
                            color: _doorStatus.isLocked
                                ? AppColors.red
                                : AppColors.green,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Status Text
                        Text(
                          _doorStatus.isLocked
                              ? 'Door is Locked'
                              : 'Door is Unlocked',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                text: 'Unlock',
                                icon: Icons.lock_open,
                                onPressed: _doorStatus.isLocked && !_isLoading
                                    ? () => _toggleDoor(false)
                                    : null,
                                backgroundColor: AppColors.green.withOpacity(0.2),
                                borderColor: AppColors.green.withOpacity(0.3),
                                textColor: AppColors.green,
                                isOutlined: true,
                                height: 48,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomButton(
                                text: 'Lock',
                                icon: Icons.lock,
                                onPressed: !_doorStatus.isLocked && !_isLoading
                                    ? () => _toggleDoor(true)
                                    : null,
                                backgroundColor: AppColors.red.withOpacity(0.2),
                                borderColor: AppColors.red.withOpacity(0.3),
                                textColor: AppColors.red,
                                isOutlined: true,
                                height: 48,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Authentication Methods
                  const Text(
                    'Authentication Methods',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildAuthMethodCard(
                          icon: Icons.fingerprint,
                          label: 'Fingerprint',
                          onTap: () => widget.onNavigate('fingerprint-settings'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildAuthMethodCard(
                          icon: Icons.qr_code_scanner,
                          label: 'QR Code',
                          onTap: () => widget.onNavigate('qr-scan'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildAuthMethodCard(
                          icon: Icons.vpn_key,
                          label: 'PIN',
                          onTap: () => widget.onNavigate('auth-selection'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Recent Activity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Activity',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: () => widget.onNavigate('activity-log'),
                        child: const Text(
                          'View All',
                          style: TextStyle(
                            color: AppColors.cyan,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Activity List
                  ..._recentActivities.map((activity) {
                    final icon = _getActivityIcon(activity.type);
                    final color = _getActivityColor(activity.type);
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: color.withOpacity(0.3),
                                ),
                              ),
                              child: Icon(
                                icon,
                                size: 20,
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
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    activity.user,
                                    style: TextStyle(
                                      color: AppColors.textCyanLight,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 12,
                                  color: AppColors.textCyanLight,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  activity.getRelativeTime(),
                                  style: TextStyle(
                                    color: AppColors.textCyanLight,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthMethodCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: AppColors.cyan,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textCyanLight,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

