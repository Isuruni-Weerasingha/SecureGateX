import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/back_button_custom.dart';

/// Help/FAQ screen
class HelpScreen extends StatefulWidget {
  final VoidCallback onBack;

  const HelpScreen({
    super.key,
    required this.onBack,
  });

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int? _expandedIndex;

  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I unlock the door using fingerprint?',
      'answer': 'Go to the Authentication Methods section on the home screen and tap on Fingerprint. Make sure your fingerprint is registered in Fingerprint Settings. Place your registered finger on the sensor to unlock.',
    },
    {
      'question': 'What happens if my fingerprint is not recognized?',
      'answer': 'If fingerprint authentication fails, you can use the PIN fallback option. Go to Settings and ensure PIN fallback is enabled. You can also use QR code or the mobile app to unlock.',
    },
    {
      'question': 'How do I grant temporary access to guests?',
      'answer': 'Navigate to Guest Access Management from the profile menu. Tap "Add New Guest" and select the authentication method (QR Code or Fingerprint). Set the duration and share the access credentials with your guest.',
    },
    {
      'question': 'How secure is the blockchain integration?',
      'answer': 'All access attempts are recorded on the blockchain, creating an immutable audit trail. Smart contracts ensure that only authorized users can unlock the door. Your biometric data is encrypted and never stored on the blockchain.',
    },
    {
      'question': 'Can I revoke guest access before it expires?',
      'answer': 'Yes, go to Guest Access Management and tap the delete icon next to the guest you want to revoke. The access will be immediately terminated.',
    },
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
                            'Help / FAQ',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Frequently asked questions',
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
                    borderColor: AppColors.cyan.withOpacity(0.2),
                    backgroundColor: AppColors.cyan.withOpacity(0.1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                              child: const Icon(
                                Icons.help_outline,
                                size: 24,
                                color: AppColors.cyan,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Need More Help?',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.cyan,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'We\'re here to assist you',
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
                        const SizedBox(height: 12),
                        Text(
                          'If you can\'t find the answer you\'re looking for, contact our support team at support@smartdoorlock.com',
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
                  ..._faqs.asMap().entries.map((entry) {
                    final index = entry.key;
                    final faq = entry.value;
                    final isExpanded = _expandedIndex == index;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _expandedIndex = isExpanded ? null : index;
                                });
                              },
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        faq['question']!,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: AppColors.cyan.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: AppColors.cyan.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Icon(
                                        isExpanded
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                        size: 20,
                                        color: AppColors.cyan,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (isExpanded)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.slate950.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.cardBorder.withOpacity(0.5),
                                    ),
                                  ),
                                  child: Text(
                                    faq['answer']!,
                                    style: TextStyle(
                                      color: AppColors.textCyanLight,
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Contact Information',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildContactRow('Email', 'support@smartdoorlock.com'),
                        _buildContactRow('Phone', '+1 (555) 123-4567'),
                        _buildContactRow('Hours', '24/7 Support'),
                      ],
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

  Widget _buildContactRow(String label, String value) {
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
              color: AppColors.cyan,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

