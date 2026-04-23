import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/back_button_custom.dart';
import '../services/door_service.dart';

class QRCodeScanScreen extends StatefulWidget {
  final VoidCallback onBack;
  const QRCodeScanScreen({super.key, required this.onBack});

  @override
  State<QRCodeScanScreen> createState() => _QRCodeScanScreenState();
}

class _QRCodeScanScreenState extends State<QRCodeScanScreen> {
  final _db = FirebaseFirestore.instance;
  final _doorService = DoorService();

  String? _tokenId;
  DateTime? _expiresAt;
  bool _isLoading = true;
  bool _isUnlocking = false;
  bool _isUnlocked = false;

  Timer? _countdownTimer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadOrCreateToken();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;
  String get _userName =>
      FirebaseAuth.instance.currentUser?.displayName ?? 'User';

  // ── Load existing valid token or create a new one ─────────────────────────
  Future<void> _loadOrCreateToken() async {
    setState(() => _isLoading = true);
    try {
      if (_uid == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Look for an existing non-expired, unused token for this user
      final existing = await _db
          .collection('qr_tokens')
          .where('userId', isEqualTo: _uid)
          .where('isUsed', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        final data = existing.docs.first.data();
        final expiresAt = (data['expiresAt'] as Timestamp).toDate();
        if (expiresAt.isAfter(DateTime.now())) {
          // Valid token exists — reuse it
          _tokenId = existing.docs.first.id;
          _expiresAt = expiresAt;
          _startCountdown();
          if (mounted) setState(() => _isLoading = false);
          return;
        }
      }

      // Create a fresh 30-minute token
      await _createToken();
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createToken() async {
    if (_uid == null) return;
    final now = DateTime.now();
    final expires = now.add(const Duration(minutes: 30));

    final doc = await _db.collection('qr_tokens').add({
      'userId': _uid,
      'userName': _userName,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(expires),
      'isUsed': false,
    });

    _tokenId = doc.id;
    _expiresAt = expires;
    _startCountdown();
    if (mounted) setState(() => _isLoading = false);
  }

  // ── Regenerate — invalidate old token, create new ────────────────────────
  Future<void> _regenerate() async {
    setState(() => _isLoading = true);
    _countdownTimer?.cancel();
    _isUnlocked = false;

    // Mark old token as used/expired so it can't be replayed
    if (_tokenId != null) {
      try {
        await _db
            .collection('qr_tokens')
            .doc(_tokenId)
            .update({'isUsed': true});
      } catch (_) {}
    }

    await _createToken();
  }

  // ── Use QR to unlock door ────────────────────────────────────────────────
  Future<void> _unlockWithQR() async {
    if (_tokenId == null || _expiresAt == null) return;
    if (_expiresAt!.isBefore(DateTime.now())) {
      _showSnack('QR code has expired. Please regenerate.', AppColors.red);
      return;
    }

    setState(() => _isUnlocking = true);
    try {
      // Mark token as used in Firestore
      await _db
          .collection('qr_tokens')
          .doc(_tokenId)
          .update({'isUsed': true, 'usedAt': FieldValue.serverTimestamp()});

      // Unlock the door
      await _doorService.unlockDoor();

      if (!mounted) return;
      setState(() {
        _isUnlocking = false;
        _isUnlocked = true;
      });
      _countdownTimer?.cancel();

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) widget.onBack();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUnlocking = false);
      _showSnack('Failed to unlock: $e', AppColors.red);
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_expiresAt == null) return;
      final rem = _expiresAt!.difference(DateTime.now());
      if (rem.isNegative) {
        _countdownTimer?.cancel();
        if (mounted) setState(() => _remaining = Duration.zero);
      } else {
        if (mounted) setState(() => _remaining = rem);
      }
    });
    _remaining = _expiresAt!.difference(DateTime.now());
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ));
  }

  String get _countdownLabel {
    if (_remaining.isNegative || _remaining == Duration.zero) {
      return 'Expired';
    }
    final m = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  bool get _isExpired =>
      _expiresAt != null && _expiresAt!.isBefore(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration:
            const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    BackButtonCustom(onPressed: widget.onBack),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('QR Code Access',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        Text('Scan to unlock the door',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textCyanLight)),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppConstants.spacingMD),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                            maxWidth: AppConstants.maxMobileWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_isLoading)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(48),
                                  child: CircularProgressIndicator(
                                      color: AppColors.cyan),
                                ),
                              )
                            else if (_uid == null)
                              GlassCard(
                                padding: const EdgeInsets.all(24),
                                child: const Text(
                                  'Please log in to generate a QR code.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppColors.textCyanLight),
                                ),
                              )
                            else ...[
                              // ── QR Card ─────────────────────────────
                              GlassCard(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  children: [
                                    // Status badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _isUnlocked
                                            ? AppColors.green
                                                .withValues(alpha: 0.2)
                                            : _isExpired
                                                ? AppColors.red
                                                    .withValues(alpha: 0.2)
                                                : AppColors.cyan
                                                    .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        border: Border.all(
                                          color: _isUnlocked
                                              ? AppColors.green
                                                  .withValues(alpha: 0.5)
                                              : _isExpired
                                                  ? AppColors.red
                                                      .withValues(alpha: 0.5)
                                                  : AppColors.cyan
                                                      .withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _isUnlocked
                                                ? Icons.lock_open
                                                : _isExpired
                                                    ? Icons.timer_off
                                                    : Icons.timer_outlined,
                                            size: 14,
                                            color: _isUnlocked
                                                ? AppColors.green
                                                : _isExpired
                                                    ? AppColors.red
                                                    : AppColors.cyan,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            _isUnlocked
                                                ? 'Door Unlocked!'
                                                : _isExpired
                                                    ? 'Expired'
                                                    : 'Expires in $_countdownLabel',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: _isUnlocked
                                                  ? AppColors.green
                                                  : _isExpired
                                                      ? AppColors.red
                                                      : AppColors.cyan,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    // QR Code
                                    AnimatedOpacity(
                                      opacity: _isExpired ? 0.35 : 1.0,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      child: Container(
                                        width: 220,
                                        height: 220,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.cyan
                                                  .withValues(alpha: 0.2),
                                              blurRadius: 20,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: QrImageView(
                                          data: 'SGX:$_tokenId',
                                          version: QrVersions.auto,
                                          backgroundColor: Colors.white,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    Text(
                                      'Token: ${_tokenId?.substring(0, 8) ?? ''}...',
                                      style: const TextStyle(
                                        color: AppColors.textCyanLight,
                                        fontSize: 12,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Generated for: $_userName',
                                      style: const TextStyle(
                                          color: AppColors.textCyanLighter,
                                          fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // ── Unlock Button ────────────────────────
                              if (!_isUnlocked && !_isExpired)
                                GradientButton(
                                  text: _isUnlocking
                                      ? 'Unlocking...'
                                      : 'Unlock Door with QR',
                                  icon: Icons.lock_open,
                                  onPressed:
                                      _isUnlocking ? null : _unlockWithQR,
                                  width: double.infinity,
                                  height: 52,
                                ),

                              const SizedBox(height: 12),

                              // ── Regenerate Button ────────────────────
                              CustomButton(
                                text: _isExpired
                                    ? 'Generate New QR'
                                    : 'Regenerate QR',
                                icon: Icons.refresh,
                                onPressed:
                                    _isLoading ? null : _regenerate,
                                backgroundColor:
                                    AppColors.cardBackground,
                                borderColor:
                                    AppColors.cyan.withValues(alpha: 0.4),
                                textColor: AppColors.cyan,
                                isOutlined: true,
                                width: double.infinity,
                                height: 48,
                              ),

                              const SizedBox(height: 24),

                              // ── Info card ────────────────────────────
                              GlassCard(
                                padding: const EdgeInsets.all(16),
                                borderColor:
                                    AppColors.blue.withValues(alpha: 0.2),
                                backgroundColor:
                                    AppColors.blue.withValues(alpha: 0.08),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline,
                                        color: AppColors.blue
                                            .withValues(alpha: 0.8),
                                        size: 18),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Text(
                                        'Each QR token is unique, one-time-use, and expires in 30 minutes. Tokens are verified against Firebase before unlocking.',
                                        style: TextStyle(
                                            color: AppColors.textCyanLighter,
                                            fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
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
