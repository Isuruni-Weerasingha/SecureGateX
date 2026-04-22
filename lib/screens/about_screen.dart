import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_glass_card.dart';
import '../widgets/back_button_custom.dart';

/// About screen
class AboutScreen extends StatelessWidget {
  final VoidCallback onBack;

  const AboutScreen({
    super.key,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final technologies = [
      {'icon': Icons.shield, 'name': 'Blockchain', 'desc': 'Ethereum smart contracts', 'color': AppColors.purple},
      {'icon': Icons.smartphone, 'name': 'Android', 'desc': 'Native mobile development', 'color': AppColors.green},
      {'icon': Icons.storage, 'name': 'Firebase', 'desc': 'Real-time database', 'color': AppColors.yellow},
      {'icon': Icons.fingerprint, 'name': 'Biometrics', 'desc': 'Fingerprint authentication', 'color': AppColors.cyan},
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
                            'About Us',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Project information',
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
                  GradientGlassCard(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.cyan, AppColors.blue],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.cyan.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              const Center(
                                child: Icon(
                                  Icons.lock,
                                  size: 48,
                                  color: Colors.white,
                                ),
                              ),
                              Positioned(
                                bottom: -4,
                                right: -4,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [AppColors.blue, AppColors.indigo],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.blue.withOpacity(0.5),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.shield,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Smart Door Lock System',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Using Blockchain Technology',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.cyan,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cyan.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.cyan.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            'Version ${AppConstants.appVersion}',
                            style: const TextStyle(
                              color: AppColors.cyan,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Project Overview',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'A secure and innovative smart door lock system that leverages blockchain technology to provide tamper-proof access control. This system combines modern biometric authentication with decentralized security to ensure maximum protection for your home or office.',
                          style: TextStyle(
                            color: AppColors.textCyanLight,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'The application features fingerprint authentication, QR code scanning, PIN access, and real-time activity logging, all secured through smart contracts on the Ethereum blockchain.',
                          style: TextStyle(
                            color: AppColors.textCyanLight,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Technologies Used',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: technologies.length,
                    itemBuilder: (context, index) {
                      final tech = technologies[index];
                      return GlassCard(
                        padding: const EdgeInsets.all(16),
                        borderColor: (tech['color'] as Color).withOpacity(0.3),
                        backgroundColor: (tech['color'] as Color).withOpacity(0.1),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: (tech['color'] as Color).withOpacity(0.3),
                                ),
                              ),
                              child: Icon(
                                tech['icon'] as IconData,
                                size: 28,
                                color: tech['color'] as Color,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              tech['name'] as String,
                              style: TextStyle(
                                color: tech['color'] as Color,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tech['desc'] as String,
                              style: TextStyle(
                                color: AppColors.textCyanLight,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    borderColor: AppColors.blue.withOpacity(0.2),
                    backgroundColor: AppColors.blue.withOpacity(0.1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.blue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.blue.withOpacity(0.3),
                                ),
                              ),
                              child: const Icon(
                                Icons.code,
                                size: 24,
                                color: AppColors.blue,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Final Year Project',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.blue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Academic Year 2025-2026',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textCyanLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('Institution', 'University of Technology'),
                        _buildInfoRow('Department', 'Computer Science'),
                        _buildInfoRow('Supervisor', 'Dr. Smith Johnson'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Key Features',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...[
                          'Blockchain-based security',
                          'Multi-factor authentication',
                          'Real-time activity monitoring',
                          'Guest access management',
                          'Biometric fingerprint unlock',
                          'QR code scanning',
                          'PIN code access',
                          'Smart contract integration',
                        ].map((feature) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.cyan,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    feature,
                                    style: TextStyle(
                                      color: AppColors.textCyanLight,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Next button to continue flow
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('help');
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textCyanLight,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

