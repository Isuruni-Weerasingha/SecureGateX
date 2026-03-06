import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/back_button_custom.dart';

/// Authentication selection screen
class AuthenticationSelectionScreen extends StatelessWidget {
  final Function(String screen) onNavigate;
  final VoidCallback onBack;

  const AuthenticationSelectionScreen({
    super.key,
    required this.onNavigate,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final authMethods = [
      {
        'icon': Icons.fingerprint,
        'title': 'Fingerprint Authentication',
        'description': 'Use your fingerprint to unlock',
        'screen': 'fingerprint-settings',
        'color': AppColors.cyan,
      },
      {
        'icon': Icons.qr_code_scanner,
        'title': 'QR Code Scan',
        'description': 'Scan QR code to unlock',
        'screen': 'qr-scan',
        'color': AppColors.blue,
      },
      {
        'icon': Icons.vpn_key,
        'title': 'PIN Authentication',
        'description': 'Enter PIN to unlock',
        'screen': 'auth-selection',
        'color': AppColors.indigo,
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
                  Row(
                    children: [
                      BackButtonCustom(onPressed: onBack),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choose Authentication',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Select your preferred method',
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
                  ...authMethods.map((method) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GlassCard(
                        padding: const EdgeInsets.all(20),
                        onTap: () => onNavigate(method['screen'] as String),
                        child: Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: (method['color'] as Color).withOpacity(0.3),
                                ),
                              ),
                              child: Icon(
                                method['icon'] as IconData,
                                size: 32,
                                color: method['color'] as Color,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    method['title'] as String,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    method['description'] as String,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textCyanLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: (method['color'] as Color),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'All authentication methods are secured by blockchain technology',
                      style: TextStyle(
                        color: AppColors.textCyanLighter,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Next button to continue flow
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('fingerprint-settings');
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

