import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_colors.dart';
import '../widgets/back_button_custom.dart';
import '../services/door_service.dart';

class PinAuthScreen extends StatefulWidget {
  final VoidCallback onBack;
  const PinAuthScreen({super.key, required this.onBack});

  @override
  State<PinAuthScreen> createState() => _PinAuthScreenState();
}

class _PinAuthScreenState extends State<PinAuthScreen>
    with SingleTickerProviderStateMixin {
  final _doorService = DoorService();

  String _entered = '';
  String? _storedPin;
  bool _isLoadingPin = true;
  bool _isVerifying = false;
  bool _hasError = false;
  bool _isSuccess = false;

  late final AnimationController _shakeCtrl;
  late final Animation<Offset> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _shakeAnim = TweenSequence<Offset>([
      TweenSequenceItem(
          tween: Tween(begin: Offset.zero, end: const Offset(-0.06, 0)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(
              begin: const Offset(-0.06, 0), end: const Offset(0.06, 0)),
          weight: 2),
      TweenSequenceItem(
          tween: Tween(
              begin: const Offset(0.06, 0), end: const Offset(-0.04, 0)),
          weight: 2),
      TweenSequenceItem(
          tween:
              Tween(begin: const Offset(-0.04, 0), end: Offset.zero),
          weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));

    _loadStoredPin();
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStoredPin() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        _storedPin = doc.data()?['pin'] as String?;
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoadingPin = false);
  }

  void _onKey(String digit) {
    if (_isVerifying || _isSuccess || _entered.length >= 4) return;
    setState(() {
      _entered += digit;
      _hasError = false;
    });
    if (_entered.length == 4) _verify();
  }

  void _onDelete() {
    if (_isVerifying || _isSuccess || _entered.isEmpty) return;
    setState(() {
      _entered = _entered.substring(0, _entered.length - 1);
      _hasError = false;
    });
  }

  Future<void> _verify() async {
    if (_storedPin == null || _storedPin!.isEmpty) {
      _triggerError('No PIN set. Go to Settings → Change PIN.');
      return;
    }

    setState(() => _isVerifying = true);
    await Future.delayed(const Duration(milliseconds: 200));

    if (_entered == _storedPin) {
      try {
        await _doorService.unlockDoor();
        if (!mounted) return;
        setState(() {
          _isVerifying = false;
          _isSuccess = true;
        });
        await Future.delayed(const Duration(milliseconds: 1800));
        if (mounted) widget.onBack();
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isVerifying = false;
          _entered = '';
        });
        _showSnack('Failed to unlock door: $e', AppColors.red);
      }
    } else {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _hasError = true;
      });
      _shakeCtrl.forward(from: 0);
      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted) {
        setState(() {
          _entered = '';
          _hasError = false;
        });
      }
    }
  }

  void _triggerError(String message) {
    setState(() {
      _hasError = true;
      _entered = '';
    });
    _shakeCtrl.forward(from: 0);
    _showSnack(message, AppColors.yellow);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _hasError = false);
    });
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ));
  }

  // ── Dot indicator for each PIN position ──────────────────────────────────
  Widget _dot(int index) {
    final filled = index < _entered.length;
    final Color color = _isSuccess
        ? AppColors.green
        : _hasError
            ? AppColors.red
            : AppColors.cyan;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? color : Colors.transparent,
        border: Border.all(
          color: filled ? color : AppColors.cardBorder,
          width: 2,
        ),
        boxShadow: filled
            ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8)]
            : null,
      ),
    );
  }

  // ── Single keypad key ─────────────────────────────────────────────────────
  Widget _key(String label, {VoidCallback? onTap, Widget? child}) {
    final bool isDisabled = _isVerifying || _isSuccess;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDisabled
              ? AppColors.cardBackground.withValues(alpha: 0.4)
              : AppColors.cardBackground.withValues(alpha: 0.8),
          border: Border.all(
            color: isDisabled
                ? AppColors.cardBorder.withValues(alpha: 0.3)
                : AppColors.cardBorder,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: child ??
              Text(
                label,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: isDisabled ? Colors.white38 : Colors.white,
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
    ];

    return Column(
      children: [
        ...rows.map((row) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: row
                    .map((d) => Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 14),
                          child: _key(d, onTap: () => _onKey(d)),
                        ))
                    .toList(),
              ),
            )),
        // Bottom row: delete | 0 | confirm
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: _key(
                '',
                onTap: _onDelete,
                child: Icon(
                  Icons.backspace_outlined,
                  color: (_isVerifying || _isSuccess)
                      ? Colors.white38
                      : AppColors.textCyanLight,
                  size: 22,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: _key('0', onTap: () => _onKey('0')),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: _key(
                '',
                onTap: _entered.length == 4 ? _verify : null,
                child: Icon(
                  Icons.check_rounded,
                  color: _entered.length == 4 && !_isVerifying && !_isSuccess
                      ? AppColors.cyan
                      : Colors.white24,
                  size: 26,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration:
            const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    BackButtonCustom(onPressed: widget.onBack),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PIN Authentication',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        Text('Enter your 4-digit PIN',
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
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: size.height * 0.04),

                        // ── Lock icon ─────────────────────────────────
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isSuccess
                                ? AppColors.green.withValues(alpha: 0.15)
                                : _hasError
                                    ? AppColors.red.withValues(alpha: 0.15)
                                    : AppColors.cyan.withValues(alpha: 0.1),
                            border: Border.all(
                              color: _isSuccess
                                  ? AppColors.green.withValues(alpha: 0.4)
                                  : _hasError
                                      ? AppColors.red.withValues(alpha: 0.4)
                                      : AppColors.cyan.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            _isSuccess
                                ? Icons.lock_open_rounded
                                : _hasError
                                    ? Icons.lock_rounded
                                    : Icons.lock_outline_rounded,
                            size: 40,
                            color: _isSuccess
                                ? AppColors.green
                                : _hasError
                                    ? AppColors.red
                                    : AppColors.cyan,
                          ),
                        ),

                        SizedBox(height: size.height * 0.03),

                        // ── Status text ───────────────────────────────
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            _isSuccess
                                ? 'Door Unlocked!'
                                : _hasError
                                    ? 'Incorrect PIN'
                                    : _isLoadingPin
                                        ? 'Loading...'
                                        : _isVerifying
                                            ? 'Verifying...'
                                            : 'Enter PIN',
                            key: ValueKey(_isSuccess
                                ? 'success'
                                : _hasError
                                    ? 'error'
                                    : _isVerifying
                                        ? 'verifying'
                                        : 'idle'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: _isSuccess
                                  ? AppColors.green
                                  : _hasError
                                      ? AppColors.red
                                      : Colors.white,
                            ),
                          ),
                        ),

                        SizedBox(height: size.height * 0.04),

                        // ── PIN dots ──────────────────────────────────
                        SlideTransition(
                          position: _shakeAnim,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              4,
                              (i) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: _dot(i),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: size.height * 0.06),

                        // ── Keypad ────────────────────────────────────
                        if (_isLoadingPin)
                          const CircularProgressIndicator(
                              color: AppColors.cyan)
                        else
                          _buildKeypad(),

                        SizedBox(height: size.height * 0.04),

                        // ── Forgot PIN hint ───────────────────────────
                        if (!_isSuccess)
                          TextButton(
                            onPressed: () =>
                                Navigator.of(context).pushNamed('settings'),
                            child: const Text(
                              'Forgot PIN? Set it in Settings',
                              style: TextStyle(
                                  color: AppColors.textCyanLight,
                                  fontSize: 13),
                            ),
                          ),

                        SizedBox(height: size.height * 0.02),
                      ],
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
