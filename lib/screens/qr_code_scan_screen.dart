import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/back_button_custom.dart';

/// QR code generator screen
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
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _qrData;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _generateQRCode() {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both username and password'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    final data = {
      'username': _usernameController.text,
      'password': _passwordController.text,
    };

    setState(() {
      _qrData = jsonEncode(data);
    });
  }

  void _clearQRCode() {
    setState(() {
      _qrData = null;
      _usernameController.clear();
      _passwordController.clear();
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
                  // Header
                  Row(
                    children: [
                      BackButtonCustom(onPressed: widget.onBack),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'QR Code Generator',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Generate QR to unlock door',
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

                  // Username Input
                  GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: TextField(
                      controller: _usernameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        labelStyle: TextStyle(color: AppColors.textCyanLight),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.person, color: AppColors.cyan),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password Input
                  GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: AppColors.textCyanLight),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.lock, color: AppColors.cyan),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Generate Button
                  CustomButton(
                    text: 'Generate QR Code',
                    onPressed: _generateQRCode,
                    icon: Icons.qr_code,
                  ),
                  const SizedBox(height: 24),

                  // QR Code Display
                  if (_qrData != null) ...[
                    GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Container(
                            width: 250,
                            height: 250,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: QrImageView(
                              data: _qrData!,
                              version: QrVersions.auto,
                              size: 250,
                              backgroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Show this QR code to unlock the door',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textCyanLight,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Generate New QR',
                      onPressed: _clearQRCode,
                      icon: Icons.refresh,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
