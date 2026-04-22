import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/back_button_custom.dart';

/// Settings screen
class SettingsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const SettingsScreen({
    super.key,
    required this.onBack,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _biometricEnabled = true;
  bool _darkMode = true;
  String _network = 'testnet';

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
                            'Settings',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'App preferences',
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

                  // Security Settings
                  const Text(
                    'Security',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Change PIN
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
                            Icons.lock,
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
                                'Change PIN',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Update your PIN code',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textCyanLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CustomButton(
                          text: 'Change',
                          onPressed: () {
                            // Placeholder
                          },
                          backgroundColor: AppColors.cyan.withOpacity(0.2),
                          borderColor: AppColors.cyan.withOpacity(0.3),
                          textColor: AppColors.cyan,
                          isOutlined: true,
                          height: 36,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Biometric Authentication
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
                                'Biometric Authentication',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Use fingerprint to unlock',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textCyanLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _biometricEnabled,
                          onChanged: (value) {
                            setState(() => _biometricEnabled = value);
                          },
                          activeColor: AppColors.cyan,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Appearance Settings
                  const Text(
                    'Appearance',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
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
                              child: Icon(
                                _darkMode ? Icons.dark_mode : Icons.light_mode,
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
                                    'Dark Mode',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Toggle dark/light theme',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textCyanLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _darkMode,
                              onChanged: (value) {
                                setState(() => _darkMode = value);
                              },
                              activeColor: AppColors.cyan,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Divider(color: AppColors.cardBorder),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _darkMode = true),
                                child: Container(
                                  height: 64,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [AppColors.slate950, Color(0xFF1E3A8A)],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _darkMode
                                          ? AppColors.cyan
                                          : AppColors.cardBorder,
                                      width: 2,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      const Center(
                                        child: Icon(
                                          Icons.dark_mode,
                                          color: AppColors.cyan,
                                          size: 24,
                                        ),
                                      ),
                                      if (_darkMode)
                                        const Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Icon(
                                            Icons.check_circle,
                                            color: AppColors.cyan,
                                            size: 16,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _darkMode = false),
                                child: Container(
                                  height: 64,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [Color(0xFFF1F5F9), Color(0xFFDBEAFE)],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: !_darkMode
                                          ? AppColors.cyan
                                          : Colors.grey.shade300,
                                      width: 2,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      const Center(
                                        child: Icon(
                                          Icons.light_mode,
                                          color: Colors.grey,
                                          size: 24,
                                        ),
                                      ),
                                      if (!_darkMode)
                                        const Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Icon(
                                            Icons.check_circle,
                                            color: AppColors.cyan,
                                            size: 16,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Blockchain Settings
                  const Text(
                    'Blockchain',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.purple.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.purple.withOpacity(0.3),
                                ),
                              ),
                              child: const Icon(
                                Icons.account_tree,
                                size: 24,
                                color: AppColors.purple,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Network Selection',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Choose blockchain network',
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
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _network = 'testnet'),
                                child: Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: _network == 'testnet'
                                        ? AppColors.cyan.withOpacity(0.2)
                                        : AppColors.cardBackground,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _network == 'testnet'
                                          ? AppColors.cyan
                                          : AppColors.cardBorder,
                                      width: 2,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Testnet',
                                              style: TextStyle(
                                                color: _network == 'testnet'
                                                    ? AppColors.cyan
                                                    : AppColors.textCyanLight,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Development',
                                              style: TextStyle(
                                                color: AppColors.textCyanLighter,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (_network == 'testnet')
                                        const Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Icon(
                                            Icons.check_circle,
                                            color: AppColors.cyan,
                                            size: 16,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _network = 'mainnet'),
                                child: Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: _network == 'mainnet'
                                        ? AppColors.green.withOpacity(0.2)
                                        : AppColors.cardBackground,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _network == 'mainnet'
                                          ? AppColors.green
                                          : AppColors.cardBorder,
                                      width: 2,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Mainnet',
                                              style: TextStyle(
                                                color: _network == 'mainnet'
                                                    ? AppColors.green
                                                    : AppColors.textCyanLight,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Production',
                                              style: TextStyle(
                                                color: AppColors.textCyanLighter,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (_network == 'mainnet')
                                        const Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Icon(
                                            Icons.check_circle,
                                            color: AppColors.green,
                                            size: 16,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Save Button
                  GradientButton(
                    text: 'Save Settings',
                    onPressed: () {
                      // Placeholder
                    },
                    width: double.infinity,
                    height: 56,
                  ),

                  const SizedBox(height: 16),

                  // Warning
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    borderColor: AppColors.yellow.withOpacity(0.3),
                    backgroundColor: AppColors.yellow.withOpacity(0.1),
                    child: Text(
                      'Changing network settings may require re-authentication',
                      style: TextStyle(
                        color: AppColors.yellow.withOpacity(0.7),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Next button to continue flow
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('smart-contract');
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

