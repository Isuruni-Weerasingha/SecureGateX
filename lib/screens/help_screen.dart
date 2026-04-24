import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/back_button_custom.dart';

class HelpScreen extends StatefulWidget {
  final VoidCallback onBack;
  const HelpScreen({super.key, required this.onBack});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int? _expandedIndex;

  // Static fallback FAQs shown while Firestore loads or if empty
  static const _staticFaqs = [
    {
      'question': 'How do I unlock the door using fingerprint?',
      'answer':
          'Go to Authentication Methods on the home screen and tap Fingerprint. Make sure your fingerprint is registered in Fingerprint Settings.',
    },
    {
      'question': 'What happens if my fingerprint is not recognized?',
      'answer':
          'Use the PIN fallback option. Go to Settings and ensure PIN fallback is enabled. You can also use QR code or PIN to unlock.',
    },
    {
      'question': 'How do I grant temporary access to guests?',
      'answer':
          'Navigate to Guest Access from the profile menu. Tap "Add New Guest", select the method and duration, then share the credentials.',
    },
    {
      'question': 'How secure is the blockchain integration?',
      'answer':
          'All access attempts are recorded on the blockchain creating an immutable audit trail. Smart contracts ensure only authorized users can unlock.',
    },
    {
      'question': 'Can I revoke guest access before it expires?',
      'answer':
          'Yes. Go to Guest Access and tap the delete icon next to the guest. Access is immediately revoked.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.all(size.width * 0.04),
                child: Row(children: [
                  BackButtonCustom(onPressed: widget.onBack),
                  SizedBox(width: size.width * 0.04),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Help / FAQ',
                        style: TextStyle(
                            fontSize: size.width * 0.05,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    Text('Frequently asked questions',
                        style: TextStyle(
                            fontSize: size.width * 0.035,
                            color: AppColors.textCyanLight)),
                  ]),
                ]),
              ),

              // ── Body ────────────────────────────────────────────────────
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  // Load FAQs from Firestore; falls back to static list if empty
                  stream: FirebaseFirestore.instance
                      .collection('faqs')
                      .orderBy('order')
                      .snapshots(),
                  builder: (context, snapshot) {
                    // Build FAQ list: prefer Firestore data, fallback to static
                    final List<Map<String, String>> faqs;
                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      faqs = snapshot.data!.docs.map((doc) {
                        final d = doc.data() as Map<String, dynamic>;
                        return {
                          'question': d['question'] as String? ?? '',
                          'answer': d['answer'] as String? ?? '',
                        };
                      }).toList();
                    } else {
                      faqs = List<Map<String, String>>.from(_staticFaqs);
                    }

                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.04),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                            maxWidth: AppConstants.maxMobileWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Support banner
                            GlassCard(
                              padding: EdgeInsets.all(size.width * 0.05),
                              borderColor: AppColors.cyan.withOpacity(0.2),
                              backgroundColor: AppColors.cyan.withOpacity(0.1),
                              child: Row(children: [
                                Container(
                                  width: size.width * 0.12,
                                  height: size.width * 0.12,
                                  decoration: BoxDecoration(
                                    color: AppColors.cyan.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: AppColors.cyan.withOpacity(0.3)),
                                  ),
                                  child: Icon(Icons.help_outline,
                                      size: size.width * 0.06,
                                      color: AppColors.cyan),
                                ),
                                SizedBox(width: size.width * 0.04),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Need More Help?',
                                          style: TextStyle(
                                              fontSize: size.width * 0.04,
                                              color: AppColors.cyan,
                                              fontWeight: FontWeight.w600)),
                                      SizedBox(height: size.height * 0.005),
                                      Text(
                                        'Contact us at support@securegate.com',
                                        style: TextStyle(
                                            fontSize: size.width * 0.03,
                                            color: AppColors.textCyanLight),
                                      ),
                                    ],
                                  ),
                                ),
                              ]),
                            ),

                            SizedBox(height: size.height * 0.025),

                            // FAQ accordion items
                            ...faqs.asMap().entries.map((entry) {
                              final i = entry.key;
                              final faq = entry.value;
                              final isExpanded = _expandedIndex == i;

                              return Padding(
                                padding: EdgeInsets.only(
                                    bottom: size.height * 0.015),
                                child: GlassCard(
                                  padding: EdgeInsets.zero,
                                  child: Column(children: [
                                    // Question row
                                    InkWell(
                                      onTap: () => setState(() =>
                                          _expandedIndex =
                                              isExpanded ? null : i),
                                      borderRadius: BorderRadius.vertical(
                                          top: const Radius.circular(16),
                                          bottom: Radius.circular(
                                              isExpanded ? 0 : 16)),
                                      child: Padding(
                                        padding:
                                            EdgeInsets.all(size.width * 0.04),
                                        child: Row(children: [
                                          Expanded(
                                            child: Text(faq['question']!,
                                                style: TextStyle(
                                                    fontSize: size.width * 0.038,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                    height: 1.4)),
                                          ),
                                          SizedBox(width: size.width * 0.03),
                                          Container(
                                            width: size.width * 0.08,
                                            height: size.width * 0.08,
                                            decoration: BoxDecoration(
                                              color: AppColors.cyan
                                                  .withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: AppColors.cyan
                                                      .withOpacity(0.3)),
                                            ),
                                            child: Icon(
                                              isExpanded
                                                  ? Icons.keyboard_arrow_up
                                                  : Icons.keyboard_arrow_down,
                                              size: size.width * 0.05,
                                              color: AppColors.cyan,
                                            ),
                                          ),
                                        ]),
                                      ),
                                    ),
                                    // Answer (animated expand)
                                    AnimatedCrossFade(
                                      firstChild: const SizedBox.shrink(),
                                      secondChild: Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            size.width * 0.04,
                                            0,
                                            size.width * 0.04,
                                            size.width * 0.04),
                                        child: Container(
                                          padding:
                                              EdgeInsets.all(size.width * 0.04),
                                          decoration: BoxDecoration(
                                            color: AppColors.slate950
                                                .withOpacity(0.5),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                color: AppColors.cardBorder
                                                    .withOpacity(0.5)),
                                          ),
                                          child: Text(faq['answer']!,
                                              style: TextStyle(
                                                  color:
                                                      AppColors.textCyanLight,
                                                  fontSize: size.width * 0.035,
                                                  height: 1.5)),
                                        ),
                                      ),
                                      crossFadeState: isExpanded
                                          ? CrossFadeState.showSecond
                                          : CrossFadeState.showFirst,
                                      duration:
                                          const Duration(milliseconds: 200),
                                    ),
                                  ]),
                                ),
                              );
                            }),

                            SizedBox(height: size.height * 0.025),

                            // Contact card
                            GlassCard(
                              padding: EdgeInsets.all(size.width * 0.05),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Contact Information',
                                      style: TextStyle(
                                          fontSize: size.width * 0.04,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600)),
                                  SizedBox(height: size.height * 0.015),
                                  _contactRow(size, 'Email',
                                      'securegatex@gmail.com'),
                                  _contactRow(size, 'Phone', '011-2204517'),
                                  _contactRow(size, 'Hours', '24/7 Support'),
                                ],
                              ),
                            ),

                            SizedBox(height: size.height * 0.03),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contactRow(Size size, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.012),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: AppColors.textCyanLight,
                  fontSize: size.width * 0.035)),
          Text(value,
              style: TextStyle(
                  color: AppColors.cyan, fontSize: size.width * 0.035)),
        ],
      ),
    );
  }
}
