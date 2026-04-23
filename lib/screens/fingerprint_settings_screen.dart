import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/back_button_custom.dart';

class FingerprintSettingsScreen extends StatefulWidget {
  final VoidCallback onBack;
  const FingerprintSettingsScreen({super.key, required this.onBack});

  @override
  State<FingerprintSettingsScreen> createState() =>
      _FingerprintSettingsScreenState();
}

class _FingerprintSettingsScreenState
    extends State<FingerprintSettingsScreen> {
  final _db = FirebaseFirestore.instance;
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  bool _fingerprintEnabled = true;
  bool _pinFallbackEnabled = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // ── Load settings from Firestore users/{uid} ──────────────────────────────
  Future<void> _loadSettings() async {
    if (_uid == null) return;
    final doc = await _db.collection('users').doc(_uid).get();
    final data = doc.data();
    if (data != null && mounted) {
      setState(() {
        _fingerprintEnabled =
            data['fingerprintEnabled'] as bool? ?? true;
        _pinFallbackEnabled =
            data['pinFallbackEnabled'] as bool? ?? true;
      });
    }
  }

  // ── Persist toggle change immediately ────────────────────────────────────
  Future<void> _saveSettings() async {
    if (_uid == null) return;
    setState(() => _isSaving = true);
    try {
      await _db.collection('users').doc(_uid).update({
        'fingerprintEnabled': _fingerprintEnabled,
        'pinFallbackEnabled': _pinFallbackEnabled,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved'),
            backgroundColor: AppColors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: AppColors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Fingerprints sub-collection stream ───────────────────────────────────
  Stream<QuerySnapshot>? get _fingerprintsStream => _uid == null
      ? null
      : _db
          .collection('users')
          .doc(_uid)
          .collection('fingerprints')
          .snapshots();

  Future<void> _addFingerprint(String name) async {
    if (_uid == null) return;
    await _db
        .collection('users')
        .doc(_uid)
        .collection('fingerprints')
        .add({
      'name': name,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _deleteFingerprint(String docId) async {
    if (_uid == null) return;
    await _db
        .collection('users')
        .doc(_uid)
        .collection('fingerprints')
        .doc(docId)
        .delete();
  }

  void _showAddDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B263B),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Fingerprint',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Fingerprint Name',
            labelStyle: TextStyle(color: AppColors.textCyanLight),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.cardBorder),
                borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.cyan),
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: TextStyle(color: AppColors.textCyanLight))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cyan,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              await _addFingerprint(ctrl.text.trim());
            },
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
                    BackButtonCustom(onPressed: widget.onBack),
                    SizedBox(width: size.width * 0.04),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Fingerprint Settings',
                          style: TextStyle(
                              fontSize: size.width * 0.05,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      Text('Manage biometric access',
                          style: TextStyle(
                              fontSize: size.width * 0.035,
                              color: AppColors.textCyanLight)),
                    ]),
                  ]),

                  SizedBox(height: size.height * 0.025),

                  // ── Enable Fingerprint Toggle ──────────────────────────
                  GlassCard(
                    padding: EdgeInsets.all(size.width * 0.05),
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
                        child: Icon(Icons.fingerprint,
                            size: size.width * 0.06, color: AppColors.cyan),
                      ),
                      SizedBox(width: size.width * 0.04),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Enable Fingerprint',
                                  style: TextStyle(
                                      fontSize: size.width * 0.04,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600)),
                              Text('Use biometric authentication',
                                  style: TextStyle(
                                      fontSize: size.width * 0.03,
                                      color: AppColors.textCyanLight)),
                            ]),
                      ),
                      Switch(
                        value: _fingerprintEnabled,
                        onChanged: (v) =>
                            setState(() => _fingerprintEnabled = v),
                        activeColor: AppColors.cyan,
                      ),
                    ]),
                  ),

                  SizedBox(height: size.height * 0.015),

                  // ── PIN Fallback Toggle ────────────────────────────────
                  GlassCard(
                    padding: EdgeInsets.all(size.width * 0.05),
                    child: Row(children: [
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('PIN Fallback',
                                  style: TextStyle(
                                      fontSize: size.width * 0.04,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600)),
                              Text('Use PIN if fingerprint fails',
                                  style: TextStyle(
                                      fontSize: size.width * 0.03,
                                      color: AppColors.textCyanLight)),
                            ]),
                      ),
                      Switch(
                        value: _pinFallbackEnabled,
                        onChanged: (v) =>
                            setState(() => _pinFallbackEnabled = v),
                        activeColor: AppColors.cyan,
                      ),
                    ]),
                  ),

                  SizedBox(height: size.height * 0.025),

                  // ── Save Settings Button ───────────────────────────────
                  GradientButton(
                    text: 'Save Settings',
                    isLoading: _isSaving,
                    onPressed: _isSaving ? null : _saveSettings,
                    width: double.infinity,
                    height: size.height * 0.07,
                  ),

                  SizedBox(height: size.height * 0.025),

                  // ── Add Fingerprint Button ─────────────────────────────
                  CustomButton(
                    text: 'Add New Fingerprint',
                    icon: Icons.add,
                    isOutlined: true,
                    borderColor: AppColors.cyan.withOpacity(0.4),
                    textColor: AppColors.cyan,
                    width: double.infinity,
                    height: size.height * 0.07,
                    onPressed: _showAddDialog,
                  ),

                  SizedBox(height: size.height * 0.025),

                  Text('Registered Fingerprints',
                      style: TextStyle(
                          fontSize: size.width * 0.04,
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                  SizedBox(height: size.height * 0.015),

                  // ── Fingerprints from Firestore sub-collection ─────────
                  StreamBuilder<QuerySnapshot>(
                    stream: _fingerprintsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.cyan));
                      }
                      final docs = snapshot.data?.docs ?? [];
                      if (docs.isEmpty) {
                        return GlassCard(
                          padding: EdgeInsets.all(size.width * 0.04),
                          child: Text('No fingerprints registered yet.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: AppColors.textCyanLight,
                                  fontSize: size.width * 0.035)),
                        );
                      }
                      return Column(
                        children: docs.map((doc) {
                          final data =
                              doc.data() as Map<String, dynamic>;
                          final name =
                              data['name'] as String? ?? 'Fingerprint';
                          final ts =
                              data['addedAt'] as Timestamp?;
                          final date = ts != null
                              ? '${ts.toDate().day}/${ts.toDate().month}/${ts.toDate().year}'
                              : 'Unknown';

                          return Padding(
                            padding: EdgeInsets.only(
                                bottom: size.height * 0.015),
                            child: GlassCard(
                              padding: EdgeInsets.all(size.width * 0.04),
                              child: Row(children: [
                                Container(
                                  width: size.width * 0.12,
                                  height: size.width * 0.12,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                        colors: [
                                          AppColors.cyan,
                                          AppColors.blue
                                        ]),
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.fingerprint,
                                      size: size.width * 0.06,
                                      color: Colors.white),
                                ),
                                SizedBox(width: size.width * 0.04),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(name,
                                          style: TextStyle(
                                              fontSize: size.width * 0.04,
                                              color: Colors.white,
                                              fontWeight:
                                                  FontWeight.w600)),
                                      Text('Added: $date',
                                          style: TextStyle(
                                              fontSize: size.width * 0.03,
                                              color:
                                                  AppColors.textCyanLight)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: AppColors.red),
                                  onPressed: () =>
                                      _deleteFingerprint(doc.id),
                                ),
                              ]),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  SizedBox(height: size.height * 0.025),

                  // ── Info card ──────────────────────────────────────────
                  GlassCard(
                    padding: EdgeInsets.all(size.width * 0.04),
                    borderColor: AppColors.blue.withOpacity(0.2),
                    backgroundColor: AppColors.blue.withOpacity(0.1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Security Information',
                            style: TextStyle(
                                fontSize: size.width * 0.035,
                                color: AppColors.blue,
                                fontWeight: FontWeight.w600)),
                        SizedBox(height: size.height * 0.008),
                        Text(
                          'Your fingerprint settings are stored securely in the cloud and synced across sessions.',
                          style: TextStyle(
                              fontSize: size.width * 0.03,
                              color: AppColors.textCyanLighter),
                        ),
                      ],
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
