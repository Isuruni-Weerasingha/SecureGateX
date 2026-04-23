import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/back_button_custom.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onBack;
  const SettingsScreen({super.key, required this.onBack});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settingsService = SettingsService();

  bool _biometricEnabled = true;
  bool _darkMode = true;
  bool _notificationsEnabled = true;
  String _network = 'testnet';
  bool _isSyncing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _syncFromFirestore();
  }

  Future<void> _syncFromFirestore() async {
    setState(() => _isSyncing = true);
    try {
      final data = await _settingsService
          .loadSettings()
          .timeout(const Duration(seconds: 10));
      if (!mounted) return;
      setState(() {
        _biometricEnabled = data['biometricEnabled'] as bool;
        _darkMode = data['darkMode'] as bool;
        _network = data['network'] as String;
        _notificationsEnabled = data['notificationsEnabled'] as bool;
        _isSyncing = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    try {
      await _settingsService.saveSettings(
        biometricEnabled: _biometricEnabled,
        darkMode: _darkMode,
        network: _network,
        notificationsEnabled: _notificationsEnabled,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully'),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save settings: $e'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Change PIN dialog ─────────────────────────────────────────────────────
  void _showChangePinDialog() {
    final newPinCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool saving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          backgroundColor: const Color(0xFF1B263B),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text('Change PIN',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(
                  controller: newPinCtrl,
                  label: 'New PIN',
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscure: true,
                  validator: (v) {
                    if (v == null || v.length < 4) {
                      return 'Enter a 4-digit PIN';
                    }
                    if (!RegExp(r'^\d{4}$').hasMatch(v)) {
                      return 'Digits only';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _dialogField(
                  controller: confirmCtrl,
                  label: 'Confirm PIN',
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscure: true,
                  validator: (v) =>
                      v != newPinCtrl.text ? 'PINs do not match' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: TextStyle(color: AppColors.textCyanLight)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cyan,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: saving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialog(() => saving = true);
                      try {
                        await _settingsService
                            .changePin(newPinCtrl.text);
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('PIN updated successfully'),
                              backgroundColor: AppColors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } catch (e) {
                        setDialog(() => saving = false);
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                            content: Text('Failed to update PIN: $e'),
                            backgroundColor: AppColors.red,
                            behavior: SnackBarBehavior.floating,
                          ));
                        }
                      }
                    },
              child: saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Update',
                      style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Change Password dialog ────────────────────────────────────────────────
  void _showChangePasswordDialog() {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool saving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          backgroundColor: const Color(0xFF1B263B),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text('Change Password',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(
                  controller: currentCtrl,
                  label: 'Current Password',
                  obscure: true,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                _dialogField(
                  controller: newCtrl,
                  label: 'New Password',
                  obscure: true,
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Minimum 6 characters'
                      : null,
                ),
                const SizedBox(height: 12),
                _dialogField(
                  controller: confirmCtrl,
                  label: 'Confirm Password',
                  obscure: true,
                  validator: (v) =>
                      v != newCtrl.text ? 'Passwords do not match' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: TextStyle(color: AppColors.textCyanLight)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cyan,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: saving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialog(() => saving = true);
                      try {
                        await _settingsService.changePassword(
                          currentPassword: currentCtrl.text,
                          newPassword: newCtrl.text,
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Password updated successfully'),
                              backgroundColor: AppColors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } on FirebaseAuthException catch (e) {
                        setDialog(() => saving = false);
                        final msg =
                            e.code == 'wrong-password' ||
                                    e.code == 'invalid-credential'
                                ? 'Current password is incorrect'
                                : e.message ??
                                    'Failed to update password';
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                            content: Text(msg),
                            backgroundColor: AppColors.red,
                            behavior: SnackBarBehavior.floating,
                          ));
                        }
                      }
                    },
              child: saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Update',
                      style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _dialogField({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      maxLength: maxLength,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        labelStyle: TextStyle(color: AppColors.textCyanLight),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.cyan),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.red),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.red),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Row with icon + title/subtitle + fixed-width trailing widget.
  /// [trailingWidth] must be explicit so the Row never overflows.
  Widget _settingRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
    double trailingWidth = 0,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: iconColor.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, size: 24, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textCyanLight)),
            ],
          ),
        ),
        if (trailingWidth > 0) const SizedBox(width: 8),
        if (trailingWidth > 0)
          SizedBox(width: trailingWidth, child: trailing)
        else
          trailing,
      ],
    );
  }

  Widget _sectionLabel(String label) => Text(
        label,
        style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600),
      );

  Widget _themeTile({
    required bool selected,
    required List<Color> colors,
    required IconData icon,
    required String label,
    Color iconColor = AppColors.cyan,
    Color labelColor = AppColors.cyan,
  }) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? AppColors.cyan : AppColors.cardBorder,
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(height: 4),
                Text(label,
                    style: TextStyle(
                        color: labelColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          if (selected)
            const Positioned(
              top: 6,
              right: 6,
              child: Icon(Icons.check_circle,
                  color: AppColors.cyan, size: 14),
            ),
        ],
      ),
    );
  }

  Widget _networkTile({
    required bool selected,
    required String label,
    required String sublabel,
    required Color selectedColor,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: selected
            ? selectedColor.withValues(alpha: 0.15)
            : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? selectedColor : AppColors.cardBorder,
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                    style: TextStyle(
                      color: selected
                          ? selectedColor
                          : AppColors.textCyanLight,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: 2),
                Text(sublabel,
                    style: const TextStyle(
                        color: AppColors.textCyanLighter,
                        fontSize: 11)),
              ],
            ),
          ),
          if (selected)
            Positioned(
              top: 6,
              right: 6,
              child: Icon(Icons.check_circle,
                  color: selectedColor, size: 14),
            ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Container(
        decoration:
            const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Thin progress bar while syncing from Firestore
              if (_isSyncing)
                const LinearProgressIndicator(
                  color: AppColors.cyan,
                  backgroundColor: AppColors.cardBackground,
                  minHeight: 2,
                ),

              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.all(AppConstants.spacingMD),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                          maxWidth: AppConstants.maxMobileWidth),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── Header ──────────────────────────────────
                          Row(
                            children: [
                              BackButtonCustom(
                                  onPressed: widget.onBack),
                              const SizedBox(width: 16),
                              const Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text('Settings',
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                          fontWeight:
                                              FontWeight.bold)),
                                  Text('App preferences',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color:
                                              AppColors.textCyanLight)),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // ── Account ─────────────────────────────────
                          _sectionLabel('Account'),
                          const SizedBox(height: 12),

                          GlassCard(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                _settingRow(
                                  icon: Icons.person_outline,
                                  iconColor: AppColors.cyan,
                                  title: user?.displayName ?? 'User',
                                  subtitle: user?.email ?? '',
                                  trailing: const SizedBox.shrink(),
                                ),
                                const SizedBox(height: 16),
                                Divider(color: AppColors.cardBorder),
                                const SizedBox(height: 8),
                                _settingRow(
                                  icon: Icons.password,
                                  iconColor: AppColors.blue,
                                  title: 'Change Password',
                                  subtitle: 'Update your login password',
                                  trailing: SizedBox(
                                    width: 96,
                                    height: 36,
                                    child: CustomButton(
                                      text: 'Change',
                                      onPressed: _showChangePasswordDialog,
                                      backgroundColor: AppColors.blue.withValues(alpha: 0.2),
                                      borderColor: AppColors.blue.withValues(alpha: 0.3),
                                      textColor: AppColors.blue,
                                      isOutlined: true,
                                      height: 36,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ── Security ────────────────────────────────
                          _sectionLabel('Security'),
                          const SizedBox(height: 12),

                          GlassCard(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                _settingRow(
                                  icon: Icons.lock_outline,
                                  iconColor: AppColors.cyan,
                                  title: 'Change PIN',
                                  subtitle: 'Update your door access PIN',
                                  trailing: SizedBox(
                                    width: 96,
                                    height: 36,
                                    child: CustomButton(
                                      text: 'Change',
                                      onPressed: _showChangePinDialog,
                                      backgroundColor: AppColors.cyan.withValues(alpha: 0.2),
                                      borderColor: AppColors.cyan.withValues(alpha: 0.3),
                                      textColor: AppColors.cyan,
                                      isOutlined: true,
                                      height: 36,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Divider(color: AppColors.cardBorder),
                                const SizedBox(height: 8),
                                _settingRow(
                                  icon: Icons.fingerprint,
                                  iconColor: AppColors.cyan,
                                  title: 'Biometric Auth',
                                  subtitle: 'Use fingerprint to unlock',
                                  trailing: Switch(
                                    value: _biometricEnabled,
                                    onChanged: (v) => setState(
                                        () => _biometricEnabled = v),
                                    activeColor: AppColors.cyan,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ── Notifications ────────────────────────────
                          _sectionLabel('Notifications'),
                          const SizedBox(height: 12),

                          GlassCard(
                            padding: const EdgeInsets.all(20),
                            child: _settingRow(
                              icon: Icons.notifications_outlined,
                              iconColor: AppColors.indigo,
                              title: 'Push Notifications',
                              subtitle: 'Alerts for door events',
                              trailing: Switch(
                                value: _notificationsEnabled,
                                onChanged: (v) => setState(
                                    () => _notificationsEnabled = v),
                                activeColor: AppColors.cyan,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // // ── Appearance ───────────────────────────────
                          // _sectionLabel('Appearance'),
                          // const SizedBox(height: 12),

                          // GlassCard(
                          //   padding: const EdgeInsets.all(20),
                          //   child: Column(
                          //     children: [
                          //       _settingRow(
                          //         icon: _darkMode
                          //             ? Icons.dark_mode
                          //             : Icons.light_mode,
                          //         iconColor: AppColors.cyan,
                          //         title: 'Dark Mode',
                          //         subtitle: 'Toggle dark/light theme',
                          //         trailing: Switch(
                          //           value: _darkMode,
                          //           onChanged: (v) =>
                          //               setState(() => _darkMode = v),
                          //           activeColor: AppColors.cyan,
                          //         ),
                          //       ),
                          //       const SizedBox(height: 16),
                          //       Divider(color: AppColors.cardBorder),
                          //       const SizedBox(height: 16),
                          //       Row(
                          //         children: [
                          //           Expanded(
                          //             child: GestureDetector(
                          //               onTap: () => setState(
                          //                   () => _darkMode = true),
                          //               child: _themeTile(
                          //                 selected: _darkMode,
                          //                 colors: const [
                          //                   AppColors.slate950,
                          //                   Color(0xFF1E3A8A),
                          //                 ],
                          //                 icon: Icons.dark_mode,
                          //                 label: 'Dark',
                          //               ),
                          //             ),
                          //           ),
                          //           const SizedBox(width: 12),
                          //           Expanded(
                          //             child: GestureDetector(
                          //               onTap: () => setState(
                          //                   () => _darkMode = false),
                          //               child: _themeTile(
                          //                 selected: !_darkMode,
                          //                 colors: const [
                          //                   Color(0xFFF1F5F9),
                          //                   Color(0xFFDBEAFE),
                          //                 ],
                          //                 icon: Icons.light_mode,
                          //                 iconColor: Colors.grey,
                          //                 label: 'Light',
                          //                 labelColor: Colors.grey,
                          //               ),
                          //             ),
                          //           ),
                          //         ],
                          //       ),
                          //     ],
                          //   ),
                          // ),

                          // const SizedBox(height: 24),

                          // // ── Blockchain ───────────────────────────────
                          // _sectionLabel('Blockchain'),
                          // const SizedBox(height: 12),

                          // GlassCard(
                          //   padding: const EdgeInsets.all(20),
                          //   child: Column(
                          //     children: [
                          //       _settingRow(
                          //         icon: Icons.account_tree,
                          //         iconColor: AppColors.purple,
                          //         title: 'Network Selection',
                          //         subtitle: 'Choose blockchain network',
                          //         trailing: const SizedBox.shrink(),
                          //       ),
                          //       const SizedBox(height: 16),
                          //       Row(
                          //         children: [
                          //           Expanded(
                          //             child: GestureDetector(
                          //               onTap: () => setState(
                          //                   () => _network = 'testnet'),
                          //               child: _networkTile(
                          //                 selected:
                          //                     _network == 'testnet',
                          //                 label: 'Testnet',
                          //                 sublabel: 'Development',
                          //                 selectedColor: AppColors.cyan,
                          //               ),
                          //             ),
                          //           ),
                          //           const SizedBox(width: 12),
                          //           Expanded(
                          //             child: GestureDetector(
                          //               onTap: () => setState(
                          //                   () => _network = 'mainnet'),
                          //               child: _networkTile(
                          //                 selected:
                          //                     _network == 'mainnet',
                          //                 label: 'Mainnet',
                          //                 sublabel: 'Production',
                          //                 selectedColor:
                          //                     AppColors.green,
                          //               ),
                          //             ),
                          //           ),
                          //         ],
                          //       ),
                          //     ],
                          //   ),
                          // ),

                          const SizedBox(height: 24),

                          // ── Save ─────────────────────────────────────
                          GradientButton(
                            text: _isSaving
                                ? 'Saving...'
                                : 'Save Settings',
                            onPressed: _isSaving ? null : _saveSettings,
                            width: double.infinity,
                            height: 56,
                          ),

                          const SizedBox(height: 16),

                          // ── Warning note ─────────────────────────────
                          GlassCard(
                            padding: const EdgeInsets.all(16),
                            borderColor:
                                AppColors.yellow.withValues(alpha: 0.3),
                            backgroundColor:
                                AppColors.yellow.withValues(alpha: 0.1),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline,
                                    color: AppColors.yellow
                                        .withValues(alpha: 0.8),
                                    size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Changing network settings may require re-authentication.',
                                    style: TextStyle(
                                      color: AppColors.yellow
                                          .withValues(alpha: 0.8),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
