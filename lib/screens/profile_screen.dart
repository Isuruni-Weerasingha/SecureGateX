import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_glass_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/back_button_custom.dart';

/// Profile screen with user info and menu items
class ProfileScreen extends StatelessWidget {
  final String userName;
  final Function(String screen) onNavigate;
  final VoidCallback onBack;

  const ProfileScreen({
    super.key,
    required this.userName,
    required this.onNavigate,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      {
        'icon': Icons.fingerprint,
        'title': 'Fingerprint Settings',
        'description': 'Manage biometric authentication',
        'screen': 'fingerprint-settings',
        'color': AppColors.cyan,
      },
      {
        'icon': Icons.qr_code_scanner,
        'title': 'QR Settings',
        'description': 'Configure QR code access',
        'screen': 'qr-scan',
        'color': AppColors.blue,
      },
      {
        'icon': Icons.history,
        'title': 'Activity Logs',
        'description': 'View access history',
        'screen': 'activity-log',
        'color': AppColors.indigo,
      },
      {
        'icon': Icons.shield,
        'title': 'Smart Contract Status',
        'description': 'Blockchain connection info',
        'screen': 'smart-contract',
        'color': AppColors.purple,
      },
      {
        'icon': Icons.info_outline,
        'title': 'About Us',
        'description': 'Project information',
        'screen': 'about',
        'color': AppColors.green,
      },
      {
        'icon': Icons.help_outline,
        'title': 'Help / FAQ',
        'description': 'Get help and support',
        'screen': 'help',
        'color': AppColors.yellow,
      },
      {
        'icon': Icons.settings,
        'title': 'Settings',
        'description': 'App preferences',
        'screen': 'settings',
        'color': Colors.grey,
      },
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
                  // Header
                  Row(
                    children: [
                      BackButtonCustom(onPressed: onBack),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Account settings',
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

                  // User Info Card
                  GradientGlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.cyan, AppColors.blue],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.cyan.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'john.doe@email.com',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.cyan,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.green.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: AppColors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'Active',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Menu Items
                  ...menuItems.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        onTap: () => onNavigate(item['screen'] as String),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: (item['color'] as Color).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: (item['color'] as Color).withOpacity(0.3),
                                ),
                              ),
                              child: Icon(
                                item['icon'] as IconData,
                                size: 24,
                                color: item['color'] as Color,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'] as String,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['description'] as String,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textCyanLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: AppColors.cyan.withOpacity(0.6),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  // Logout Button
                  CustomButton(
                    text: 'Logout',
                    icon: Icons.logout,
                    onPressed: () => onNavigate('login'),
                    backgroundColor: AppColors.red.withOpacity(0.2),
                    borderColor: AppColors.red.withOpacity(0.5),
                    textColor: AppColors.red,
                    isOutlined: true,
                    width: double.infinity,
                    height: 56,
                  ),

                  const SizedBox(height: 24),

                  // Version Info
                  Center(
                    child: Text(
                      'Version ${AppConstants.appVersion} • Build ${AppConstants.appBuild}',
                      style: TextStyle(
                        color: AppColors.textCyanLighter,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Next button to continue flow
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('settings');
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

