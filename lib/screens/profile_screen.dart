import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_glass_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/back_button_custom.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

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

  static const _menuItems = [
    {'icon': Icons.fingerprint, 'title': 'Fingerprint Settings', 'description': 'Manage biometric authentication', 'screen': 'fingerprint-settings', 'color': AppColors.cyan},
    {'icon': Icons.qr_code_scanner, 'title': 'QR Settings', 'description': 'Configure QR code access', 'screen': 'qr-scan', 'color': AppColors.blue},
    {'icon': Icons.history, 'title': 'Activity Logs', 'description': 'View access history', 'screen': 'activity-log', 'color': AppColors.indigo},
    {'icon': Icons.shield, 'title': 'Smart Contract Status', 'description': 'Blockchain connection info', 'screen': 'smart-contract', 'color': AppColors.purple},
    {'icon': Icons.info_outline, 'title': 'About Us', 'description': 'Project information', 'screen': 'about', 'color': AppColors.green},
    {'icon': Icons.help_outline, 'title': 'Help / FAQ', 'description': 'Get help and support', 'screen': 'help', 'color': AppColors.yellow},
    {'icon': Icons.settings, 'title': 'Settings', 'description': 'App preferences', 'screen': 'settings', 'color': Colors.grey},
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(size.width * 0.04),
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: AppConstants.maxMobileWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Header ─────────────────────────────────────────────
                  Row(children: [
                    BackButtonCustom(onPressed: onBack),
                    SizedBox(width: size.width * 0.04),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Profile',
                          style: TextStyle(
                              fontSize: size.width * 0.05,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      Text('Account settings',
                          style: TextStyle(
                              fontSize: size.width * 0.035,
                              color: AppColors.textCyanLight)),
                    ]),
                  ]),

                  SizedBox(height: size.height * 0.03),

                  // ── User Info Card (loaded from Firestore) ─────────────
                  FutureBuilder<DocumentSnapshot>(
                    future: user == null
                        ? null
                        : FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .get(),
                    builder: (context, snapshot) {
                      final data =
                          snapshot.data?.data() as Map<String, dynamic>?;
                      final displayName = data?['fullName'] as String? ??
                          user?.displayName ??
                          userName;
                      final email = data?['email'] as String? ??
                          user?.email ??
                          '';
                      final phone =
                          data?['phone'] as String? ?? '';

                      return GradientGlassCard(
                        padding: EdgeInsets.all(size.width * 0.06),
                        child: Row(children: [
                          // Avatar
                          Container(
                            width: size.width * 0.2,
                            height: size.width * 0.2,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [AppColors.cyan, AppColors.blue]),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                    color: AppColors.cyan.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4))
                              ],
                            ),
                            child: Icon(Icons.person,
                                size: size.width * 0.1,
                                color: Colors.white),
                          ),
                          SizedBox(width: size.width * 0.04),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(displayName,
                                    style: TextStyle(
                                        fontSize: size.width * 0.05,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis),
                                SizedBox(height: size.height * 0.005),
                                Text(email,
                                    style: TextStyle(
                                        fontSize: size.width * 0.032,
                                        color: AppColors.cyan),
                                    overflow: TextOverflow.ellipsis),
                                if (phone.isNotEmpty) ...[
                                  SizedBox(height: size.height * 0.003),
                                  Text(phone,
                                      style: TextStyle(
                                          fontSize: size.width * 0.03,
                                          color: AppColors.textCyanLight)),
                                ],
                                SizedBox(height: size.height * 0.01),
                                // Active badge
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: size.width * 0.03,
                                      vertical: size.height * 0.006),
                                  decoration: BoxDecoration(
                                    color: AppColors.green.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color:
                                            AppColors.green.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                          width: size.width * 0.015,
                                          height: size.width * 0.015,
                                          decoration: const BoxDecoration(
                                              color: AppColors.green,
                                              shape: BoxShape.circle)),
                                      SizedBox(width: size.width * 0.015),
                                      Text('Active',
                                          style: TextStyle(
                                              fontSize: size.width * 0.03,
                                              color: AppColors.green,
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]),
                      );
                    },
                  ),

                  SizedBox(height: size.height * 0.03),

                  // ── Menu Items ─────────────────────────────────────────
                  ..._menuItems.map((item) => Padding(
                        padding:
                            EdgeInsets.only(bottom: size.height * 0.01),
                        child: GlassCard(
                          padding: EdgeInsets.all(size.width * 0.04),
                          onTap: () =>
                              onNavigate(item['screen'] as String),
                          child: Row(children: [
                            Container(
                              width: size.width * 0.12,
                              height: size.width * 0.12,
                              decoration: BoxDecoration(
                                color: (item['color'] as Color)
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: (item['color'] as Color)
                                        .withOpacity(0.3)),
                              ),
                              child: Icon(item['icon'] as IconData,
                                  size: size.width * 0.06,
                                  color: item['color'] as Color),
                            ),
                            SizedBox(width: size.width * 0.04),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(item['title'] as String,
                                      style: TextStyle(
                                          fontSize: size.width * 0.04,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600)),
                                  SizedBox(height: size.height * 0.004),
                                  Text(item['description'] as String,
                                      style: TextStyle(
                                          fontSize: size.width * 0.03,
                                          color: AppColors.textCyanLight)),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right,
                                color: AppColors.cyan.withOpacity(0.6)),
                          ]),
                        ),
                      )),

                  SizedBox(height: size.height * 0.025),

                  // ── Logout ─────────────────────────────────────────────
                  CustomButton(
                    text: 'Logout',
                    icon: Icons.logout,
                    onPressed: () async {
                      await AuthService().signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => LoginScreen(
                              onLogin: (_) {
                                Navigator.of(context).pushReplacementNamed('home');
                              },
                            ),
                          ),
                          (route) => false,
                        );
                      }
                    },
                    backgroundColor: AppColors.red.withOpacity(0.2),
                    borderColor: AppColors.red.withOpacity(0.5),
                    textColor: AppColors.red,
                    isOutlined: true,
                    width: double.infinity,
                    height: size.height * 0.07,
                  ),

                  SizedBox(height: size.height * 0.025),

                  Center(
                    child: Text(
                      'Version ${AppConstants.appVersion} • Build ${AppConstants.appBuild}',
                      style: TextStyle(
                          color: AppColors.textCyanLighter,
                          fontSize: size.width * 0.03),
                    ),
                  ),

                  SizedBox(height: size.height * 0.03),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
