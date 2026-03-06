import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/back_button_custom.dart';

/// Notifications screen
class NotificationsScreen extends StatelessWidget {
  final VoidCallback onBack;

  const NotificationsScreen({
    super.key,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {'title': 'Failed Unlock Attempt', 'message': 'Unknown person tried to access with invalid QR code', 'time': '5 minutes ago', 'type': 'warning', 'read': false},
      {'title': 'Door Unlocked', 'message': 'John Doe unlocked the front door using fingerprint', 'time': '1 hour ago', 'type': 'success', 'read': false},
      {'title': 'Guest Access Activity', 'message': 'Sarah Smith accessed the door using guest QR code', 'time': '3 hours ago', 'type': 'info', 'read': true},
    ];

    Color getColor(String type) {
      switch (type) {
        case 'warning':
          return AppColors.red;
        case 'success':
          return AppColors.green;
        case 'info':
          return AppColors.blue;
        default:
          return AppColors.cyan;
      }
    }

    IconData getIcon(String type) {
      switch (type) {
        case 'warning':
          return Icons.warning_amber_rounded;
        case 'success':
          return Icons.check_circle;
        case 'info':
          return Icons.person_add;
        default:
          return Icons.notifications;
      }
    }

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          BackButtonCustom(onPressed: onBack),
                          const SizedBox(width: 16),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notifications',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '2 unread',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textCyanLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Mark all read',
                          style: TextStyle(
                            color: AppColors.cyan,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ...notifications.map((notif) {
                    final color = getColor(notif['type'] as String);
                    final icon = getIcon(notif['type'] as String);
                    final isRead = notif['read'] as bool;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Stack(
                        children: [
                          GlassCard(
                            padding: const EdgeInsets.all(16),
                            borderColor: color.withOpacity(0.3),
                            backgroundColor: color.withOpacity(0.1),
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
                                        notif['title'] as String,
                                        style: TextStyle(
                                          color: color,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        notif['message'] as String,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        notif['time'] as String,
                                        style: TextStyle(
                                          color: AppColors.textCyanLighter,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isRead)
                            const Positioned(
                              top: 16,
                              right: 16,
                              child: Icon(
                                Icons.circle,
                                size: 8,
                                color: AppColors.cyan,
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    onTap: () {},
                    child: const Center(
                      child: Text(
                        'Clear All Notifications',
                        style: TextStyle(
                          color: AppColors.cyan,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Next button to continue flow
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('profile');
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

