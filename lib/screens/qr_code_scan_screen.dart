import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/back_button_custom.dart';

/// QR code scan screen
class QRCodeScanScreen extends StatefulWidget {
  final VoidCallback onBack;

  const QRCodeScanScreen({
    super.key,
    required this.onBack,
  });

  @override
  State<QRCodeScanScreen> createState() => _QRCodeScanScreenState();
}

class _QRCodeScanScreenState extends State<QRCodeScanScreen> {
  bool _scanning = false;
  int _timeRemaining = 60;
  String? _error;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startScan() {
    setState(() {
      _scanning = true;
      _error = null;
      _timeRemaining = 60;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() => _timeRemaining--);
      } else {
        setState(() {
          _error = 'QR Code expired. Please generate a new one.';
          _scanning = false;
        });
        timer.cancel();
      }
    });
  }

  void _stopScan() {
    _timer?.cancel();
    setState(() {
      _scanning = false;
      _timeRemaining = 60;
      _error = null;
    });
  }

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
                            'QR Code Scanner',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Scan to unlock door',
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
                  AspectRatio(
                    aspectRatio: 1,
                    child: GlassCard(
                      padding: EdgeInsets.zero,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppColors.slate900, AppColors.slate950],
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          if (_scanning)
                            Center(
                              child: Container(
                                width: 256,
                                height: 256,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.cyan,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            top: BorderSide(color: AppColors.cyan, width: 4),
                                            left: BorderSide(color: AppColors.cyan, width: 4),
                                          ),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(16),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            top: BorderSide(color: AppColors.cyan, width: 4),
                                            right: BorderSide(color: AppColors.cyan, width: 4),
                                          ),
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(16),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(color: AppColors.cyan, width: 4),
                                            left: BorderSide(color: AppColors.cyan, width: 4),
                                          ),
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(16),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(color: AppColors.cyan, width: 4),
                                            right: BorderSide(color: AppColors.cyan, width: 4),
                                          ),
                                          borderRadius: BorderRadius.only(
                                            bottomRight: Radius.circular(16),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.qr_code_scanner,
                                    size: 96,
                                    color: AppColors.textCyanLighter,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Camera preview',
                                    style: TextStyle(
                                      color: AppColors.textCyanLighter,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (_scanning) ...[
                    const SizedBox(height: 16),
                    GlassCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: AppColors.cyan,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'QR Code valid for: $_timeRemaining s',
                            style: const TextStyle(
                              color: AppColors.cyan,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      borderColor: AppColors.red.withOpacity(0.3),
                      backgroundColor: AppColors.red.withOpacity(0.1),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Scan Failed',
                                  style: TextStyle(
                                    color: AppColors.red,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _error!,
                                  style: TextStyle(
                                    color: AppColors.red.withOpacity(0.8),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  _scanning
                      ? CustomButton(
                          text: 'Stop Scanning',
                          onPressed: _stopScan,
                          backgroundColor: AppColors.red.withOpacity(0.2),
                          borderColor: AppColors.red.withOpacity(0.5),
                          textColor: AppColors.red,
                          isOutlined: true,
                          width: double.infinity,
                          height: 56,
                        )
                      : GradientButton(
                          text: 'Start Scanning',
                          onPressed: _startScan,
                          width: double.infinity,
                          height: 56,
                        ),
                  const SizedBox(height: 32),
                  const Text(
                    'How to use QR Code Scanner',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...['Tap "Start Scanning" to activate the camera',
                      'Point your camera at the QR code',
                      'Keep the QR code within the frame',
                      'The door will unlock automatically']
                      .asMap()
                      .entries
                      .map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.cyan.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.cyan.withOpacity(0.3),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${entry.key + 1}',
                                style: const TextStyle(
                                  color: AppColors.cyan,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: TextStyle(
                                color: AppColors.textCyanLight,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 32),
                  // Next button to continue flow
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('activity-log');
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

