import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/back_button_custom.dart';

/// Guest access management screen
class GuestAccessScreen extends StatelessWidget {
  final VoidCallback onBack;

  const GuestAccessScreen({
    super.key,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final guests = [
      {'name': 'Sarah Smith', 'type': 'QR Code', 'duration': '24 hours', 'remaining': '18h remaining', 'status': 'active'},
      {'name': 'Mike Johnson', 'type': 'Fingerprint', 'duration': '7 days', 'remaining': '5d remaining', 'status': 'active'},
      {'name': 'Emma Davis', 'type': 'QR Code', 'duration': '12 hours', 'remaining': 'Expired', 'status': 'expired'},
    ];

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
                    children: [
                      BackButtonCustom(onPressed: onBack),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Guest Access',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Manage temporary access',
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
                  GradientButton(
                    text: 'Add New Guest',
                    icon: Icons.person_add,
                    width: double.infinity,
                    height: 56,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Quick Duration',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: ['6 hours', '24 hours', '7 days'].map((duration) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GlassCard(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            onTap: () {},
                            child: Center(
                              child: Text(
                                duration,
                                style: const TextStyle(
                                  color: AppColors.cyan,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Active Guests (${guests.where((g) => g['status'] == 'active').length})',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...guests.map((guest) {
                    final isExpired = guest['status'] == 'expired';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        borderColor: isExpired
                            ? AppColors.red.withOpacity(0.2)
                            : AppColors.cardBorder,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isExpired
                                        ? AppColors.red.withOpacity(0.1)
                                        : AppColors.cyan.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isExpired
                                          ? AppColors.red.withOpacity(0.3)
                                          : AppColors.cyan.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Icon(
                                    guest['type'] == 'QR Code'
                                        ? Icons.qr_code_scanner
                                        : Icons.fingerprint,
                                    size: 24,
                                    color: isExpired ? AppColors.red : AppColors.cyan,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        guest['name']!,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Access: ${guest['type']}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textCyanLight,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time,
                                            size: 12,
                                            color: AppColors.textCyanLighter,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Duration: ${guest['duration']}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textCyanLighter,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: isExpired
                                        ? Colors.grey
                                        : AppColors.red,
                                  ),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isExpired
                                    ? AppColors.red.withOpacity(0.1)
                                    : AppColors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isExpired
                                      ? AppColors.red.withOpacity(0.3)
                                      : AppColors.green.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: isExpired
                                          ? AppColors.red
                                          : AppColors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    guest['remaining']!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isExpired
                                          ? AppColors.red
                                          : AppColors.green,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    borderColor: AppColors.yellow.withOpacity(0.2),
                    backgroundColor: AppColors.yellow.withOpacity(0.1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Security Reminder',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.yellow,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Guest access is temporary and secured via blockchain. Access automatically expires after the set duration. You can revoke access at any time.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textCyanLighter,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Next button to continue flow
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('notifications');
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

