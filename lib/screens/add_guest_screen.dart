import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_button.dart';
import '../services/guest_service.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AddGuestScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const AddGuestScreen({super.key, this.onBack});

  @override
  State<AddGuestScreen> createState() => _AddGuestScreenState();
}

class _AddGuestScreenState extends State<AddGuestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _guestService = GuestService();

  String _accessMethod = 'PIN';
  DateTime _expiryTime = DateTime.now().add(const Duration(hours: 24));
  String? _generatedCode;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  String _generatePIN() => (1000 + Random().nextInt(9000)).toString();

  String _generateQRPayload(String name) =>
      'SGX-${name.replaceAll(' ', '_')}-${_expiryTime.millisecondsSinceEpoch}';

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expiryTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_expiryTime),
      );
      if (time != null && mounted) {
        setState(() {
          _expiryTime = DateTime(
              date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  Future<void> _generateAndSave() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final code = _accessMethod == 'PIN'
        ? _generatePIN()
        : _generateQRPayload(name);

    setState(() {
      _isLoading = true;
      _generatedCode = null;
    });

    try {
      await _guestService.addGuestWithCode(
        name: name,
        contact: _contactController.text.trim(),
        type: _accessMethod,
        accessCode: code,
        expiresAt: _expiryTime,
      );

      if (!mounted) return;
      setState(() => _generatedCode = code);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Guest access saved successfully'),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save guest access: $e'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Guest Access'),
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              )
            : null,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacingMD),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Guest Name ──────────────────────────────────────────
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CustomInput(
                          label: 'Guest Name',
                          controller: _nameController,
                          hint: 'Enter guest name',
                          prefixIcon: Icons.person_outline,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        CustomInput(
                          label: 'Phone / Email',
                          controller: _contactController,
                          hint: 'Enter phone or email',
                          prefixIcon: Icons.contact_phone_outlined,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Access Method ───────────────────────────────────────
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Access Method',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _accessMethod,
                          dropdownColor: AppColors.cardBackground,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.cardBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: AppColors.cardBorder),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: AppColors.cardBorder),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          items: ['PIN', 'QR Code']
                              .map((m) =>
                                  DropdownMenuItem(value: m, child: Text(m)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _accessMethod = v ?? 'PIN'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Expiry Date/Time ────────────────────────────────────
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Access Expiry Time',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _selectDateTime,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: AppColors.cardBorder),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    color: AppColors.cyan, size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  DateFormat('MMM dd, yyyy – hh:mm a')
                                      .format(_expiryTime),
                                  style:
                                      const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Generate & Save Button ──────────────────────────────
                  GradientButton(
                    text: _isLoading ? 'Saving...' : 'Generate Access',
                    icon: Icons.vpn_key,
                    onPressed: _isLoading ? null : _generateAndSave,
                    width: double.infinity,
                    height: 52,
                  ),

                  // ── Generated Code Display ──────────────────────────────
                  if (_generatedCode != null) ...[
                    const SizedBox(height: 24),
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            'Generated $_accessMethod',
                            style: const TextStyle(
                              color: AppColors.cyan,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_accessMethod == 'PIN')
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppColors.cyan.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color:
                                        AppColors.cyan.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                _generatedCode!,
                                style: const TextStyle(
                                  color: AppColors.cyan,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 8,
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: QrImageView(
                                  data: _generatedCode!, size: 200),
                            ),
                          const SizedBox(height: 16),
                          Text(
                            'Valid until: ${DateFormat('MMM dd, yyyy – hh:mm a').format(_expiryTime)}',
                            style: TextStyle(
                                color: AppColors.textCyanLight,
                                fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.cloud_done,
                                  color: AppColors.green, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Saved to Firebase',
                                style: TextStyle(
                                    color: AppColors.green, fontSize: 12),
                              ),
                            ],
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
    );
  }
}
