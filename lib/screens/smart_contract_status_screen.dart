import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_glass_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/back_button_custom.dart';

/// Smart contract status screen
class SmartContractStatusScreen extends StatelessWidget {
  final VoidCallback onBack;

  const SmartContractStatusScreen({
    super.key,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    const contractAddress = '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb';
    const lastTransactionHash = '0x8f3e9c2b1a4d5e6f7c8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e';

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
                            'Smart Contract',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Blockchain status',
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
                    padding: const EdgeInsets.all(24),
                    glowColor: AppColors.green,
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.green.withOpacity(0.3),
                            ),
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            size: 32,
                            color: AppColors.green,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Connected',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppColors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Blockchain is active',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.green.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'All systems operational',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.green.withOpacity(0.7),
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
                  const SizedBox(height: 24),
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Blockchain Network',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Current network status',
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
                        _buildInfoRow('Network', 'Ethereum Testnet', isHighlight: true),
                        _buildInfoRow('Chain ID', '5'),
                        _buildInfoRow('Block Height', '12,345,678'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GlassCard(
                    padding: const EdgeInsets.all(20),
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
                                Icons.shield,
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
                                    'Smart Contract Address',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Deployed contract',
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
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.slate950.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.cardBorder.withOpacity(0.5),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                contractAddress,
                                style: TextStyle(
                                  color: AppColors.cyan,
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomButton(
                                      text: 'Copy',
                                      icon: Icons.copy,
                                      onPressed: () {
                                        Clipboard.setData(
                                          const ClipboardData(text: contractAddress),
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Address copied to clipboard'),
                                          ),
                                        );
                                      },
                                      backgroundColor: AppColors.cyan.withOpacity(0.2),
                                      borderColor: AppColors.cyan.withOpacity(0.3),
                                      textColor: AppColors.cyan,
                                      isOutlined: true,
                                      height: 36,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: CustomButton(
                                      text: 'View Explorer',
                                      icon: Icons.open_in_new,
                                      onPressed: () {
                                        // Open blockchain explorer in browser
                                        // For web: can use url_launcher package
                                        // For mobile: can use url_launcher package
                                        // Placeholder for now
                                      },
                                      backgroundColor: AppColors.blue.withOpacity(0.2),
                                      borderColor: AppColors.blue.withOpacity(0.3),
                                      textColor: AppColors.blue,
                                      isOutlined: true,
                                      height: 36,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('Contract Version', 'v1.2.0'),
                        _buildInfoRow('Deployed On', 'Jan 15, 2026'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Last Transaction',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.slate950.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.cardBorder.withOpacity(0.5),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Transaction Hash',
                                style: TextStyle(
                                  color: AppColors.textCyanLighter,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                lastTransactionHash,
                                style: TextStyle(
                                  color: AppColors.cyan,
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(height: 12),
                              CustomButton(
                                text: 'Copy Hash',
                                icon: Icons.copy,
                                onPressed: () {
                                  Clipboard.setData(
                                    const ClipboardData(text: lastTransactionHash),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Hash copied to clipboard'),
                                    ),
                                  );
                                },
                                backgroundColor: AppColors.cyan.withOpacity(0.2),
                                borderColor: AppColors.cyan.withOpacity(0.3),
                                textColor: AppColors.cyan,
                                isOutlined: true,
                                width: double.infinity,
                                height: 36,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('Timestamp', 'Feb 7, 2026 10:45 AM'),
                        _buildInfoRow('Gas Used', '21,000'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Status',
                              style: TextStyle(
                                color: AppColors.textCyanLight,
                                fontSize: 14,
                              ),
                            ),
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
                              child: const Text(
                                'Confirmed',
                                style: TextStyle(
                                  color: AppColors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  GradientButton(
                    text: 'Refresh Status',
                    onPressed: () {},
                    width: double.infinity,
                    height: 48,
                  ),
                  const SizedBox(height: 24),
                  // Next button to continue flow
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('about');
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

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
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
          if (isHighlight)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.cyan.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.cyan.withOpacity(0.3),
                ),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  color: AppColors.cyan,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'monospace',
              ),
            ),
        ],
      ),
    );
  }
}

