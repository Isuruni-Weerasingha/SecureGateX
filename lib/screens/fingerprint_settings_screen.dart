import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/back_button_custom.dart';

/// Fingerprint settings screen
class FingerprintSettingsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const FingerprintSettingsScreen({
    super.key,
    required this.onBack,
  });

  @override
  State<FingerprintSettingsScreen> createState() => _FingerprintSettingsScreenState();
}

class _FingerprintSettingsScreenState extends State<FingerprintSettingsScreen> {
  bool _fingerprintEnabled = true;
  bool _pinFallbackEnabled = true;
  
  final List<Map<String, String>> _fingerprints = [
    {'name': 'Right Thumb', 'date': 'Jan 15, 2026'},
    {'name': 'Right Index', 'date': 'Jan 15, 2026'},
    {'name': 'Left Thumb', 'date': 'Jan 20, 2026'},
  ];

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
                  Row(
                    children: [
                      BackButtonCustom(onPressed: widget.onBack),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fingerprint Settings',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Manage biometric access',
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
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.cyan.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.cyan.withOpacity(0.3),
                            ),
                          ),
                          child: const Icon(
                            Icons.fingerprint,
                            size: 24,
                            color: AppColors.cyan,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Enable Fingerprint',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Use biometric authentication',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textCyanLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _fingerprintEnabled,
                          onChanged: (value) {
                            setState(() => _fingerprintEnabled = value);
                          },
                          activeColor: AppColors.cyan,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'PIN Fallback',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Use PIN if fingerprint fails',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textCyanLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _pinFallbackEnabled,
                          onChanged: (value) {
                            setState(() => _pinFallbackEnabled = value);
                          },
                          activeColor: AppColors.cyan,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  GradientButton(
                    text: 'Add New Fingerprint',
                    icon: Icons.add,
                    width: double.infinity,
                    height: 56,
                    onPressed: () {
                      // Placeholder
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Registered Fingerprints',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._fingerprints.map((fp) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [AppColors.cyan, AppColors.blue],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.cyan.withOpacity(0.3),
                                ),
                              ),
                              child: const Icon(
                                Icons.fingerprint,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fp['name']!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Added: ${fp['date']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textCyanLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.red,
                              ),
                              onPressed: () {
                                // Placeholder
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    borderColor: AppColors.blue.withOpacity(0.2),
                    backgroundColor: AppColors.blue.withOpacity(0.1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Security Information',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your fingerprint data is encrypted and stored securely on the blockchain. It never leaves your device in an unencrypted form.',
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
                      Navigator.of(context).pushNamed('home');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cyan,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continue to Home',
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

