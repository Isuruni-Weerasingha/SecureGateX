import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/back_button_custom.dart';
import '../services/guest_service.dart';

class GuestAccessScreen extends StatelessWidget {
  final VoidCallback onBack;
  const GuestAccessScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) => _GuestAccessView(onBack: onBack);
}

class _GuestAccessView extends StatefulWidget {
  final VoidCallback onBack;
  const _GuestAccessView({required this.onBack});

  @override
  State<_GuestAccessView> createState() => _GuestAccessViewState();
}

class _GuestAccessViewState extends State<_GuestAccessView> {
  final _guestService = GuestService();

  @override
  void dispose() {
    super.dispose();
  }

  // ── Add Guest Dialog ──────────────────────────────────────────────────────
  void _showAddGuestDialog({int presetHours = 24}) {
    final nameCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String type = 'PIN';
    int hours = presetHours;
    bool saving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          backgroundColor: const Color(0xFF1B263B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add New Guest',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogField(
                    controller: nameCtrl,
                    label: 'Guest Name',
                    icon: Icons.person_outline,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  _dialogField(
                    controller: contactCtrl,
                    label: 'Phone / Email',
                    icon: Icons.contact_phone_outlined,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  _dialogDropdown<String>(
                    label: 'Access Method',
                    value: type,
                    items: const ['PIN', 'QR Code'],
                    onChanged: (v) => setDialog(() => type = v ?? 'PIN'),
                  ),
                  const SizedBox(height: 12),
                  _dialogDropdown<int>(
                    label: 'Duration',
                    value: hours,
                    items: const [6, 24, 168],
                    itemLabels: const ['6 hours', '24 hours', '7 days'],
                    onChanged: (v) => setDialog(() => hours = v ?? 24),
                  ),
                ],
              ),
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
                        final expiresAt =
                            DateTime.now().add(Duration(hours: hours));
                        final code = type == 'PIN'
                            ? (1000 + Random().nextInt(9000)).toString()
                            : 'SGX-${nameCtrl.text.trim().replaceAll(' ', '_')}-${expiresAt.millisecondsSinceEpoch}';

                        await _guestService.addGuestWithCode(
                          name: nameCtrl.text.trim(),
                          contact: contactCtrl.text.trim(),
                          type: type,
                          accessCode: code,
                          expiresAt: expiresAt,
                        );

                        if (ctx.mounted) Navigator.pop(ctx);
                        if (mounted) {
                          _showGeneratedCode(
                              type: type,
                              code: code,
                              name: nameCtrl.text.trim(),
                              expiresAt: expiresAt);
                        }
                      } catch (e) {
                        setDialog(() => saving = false);
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: AppColors.red,
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
                  : const Text('Generate Access',
                      style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Show generated PIN or QR ──────────────────────────────────────────────
  void _showGeneratedCode({
    required String type,
    required String code,
    required String name,
    required DateTime expiresAt,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B263B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Access Generated for $name',
            style: const TextStyle(
                color: AppColors.cyan, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (type == 'PIN')
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cyan.withOpacity(0.3)),
                ),
                child: Text(code,
                    style: const TextStyle(
                        color: AppColors.cyan,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8)),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: QrImageView(data: code, size: 180),
              ),
            const SizedBox(height: 12),
            Text(
              'Valid until: ${DateFormat('MMM dd, yyyy – hh:mm a').format(expiresAt)}',
              style: TextStyle(color: AppColors.textCyanLight, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.cloud_done, color: AppColors.green, size: 14),
              const SizedBox(width: 6),
              Text('Saved to database',
                  style: TextStyle(color: AppColors.green, fontSize: 12)),
            ]),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cyan,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Done', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Delete confirmation ───────────────────────────────────────────────────
  Future<void> _deleteGuest(String docId, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B263B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Revoke Access',
            style: TextStyle(color: Colors.white)),
        content: Text('Remove guest access for $name?',
            style: TextStyle(color: AppColors.textCyanLight)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.cyan))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Revoke', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) await _guestService.deleteGuest(docId);
  }

  // ── Dialog helpers ────────────────────────────────────────────────────────
  Widget _dialogField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.cyan, size: 20),
        labelStyle: TextStyle(color: AppColors.textCyanLight),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.cyan),
            borderRadius: BorderRadius.circular(12)),
        errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.red),
            borderRadius: BorderRadius.circular(12)),
        focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.red),
            borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _dialogDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    List<String>? itemLabels,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      dropdownColor: const Color(0xFF1B263B),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textCyanLight),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.cyan),
            borderRadius: BorderRadius.circular(12)),
      ),
      items: items.asMap().entries.map((e) {
        final label = itemLabels != null ? itemLabels[e.key] : '${e.value}';
        return DropdownMenuItem<T>(value: e.value, child: Text(label));
      }).toList(),
      onChanged: onChanged,
    );
  }

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
                child: Row(
                  children: [
                    BackButtonCustom(onPressed: widget.onBack),
                    SizedBox(width: size.width * 0.04),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Guest Access',
                            style: TextStyle(
                                fontSize: size.width * 0.05,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        Text('Manage temporary access',
                            style: TextStyle(
                                fontSize: size.width * 0.035,
                                color: AppColors.textCyanLight)),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Body ────────────────────────────────────────────────────
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _guestService.watchGuests(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.cloud_off, color: AppColors.red, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              'Failed to load guests:\n${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.red, fontSize: 13),
                            ),
                          ]),
                        ),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.cyan));
                    }

                    final docs = snapshot.data?.docs ?? [];
                    // Sort client-side by createdAt descending
                    final sorted = [...docs]..sort((a, b) {
                        final aTs = (a.data() as Map)['createdAt'] as Timestamp?;
                        final bTs = (b.data() as Map)['createdAt'] as Timestamp?;
                        if (aTs == null || bTs == null) return 0;
                        return bTs.compareTo(aTs);
                      });
                    final activeCount = sorted
                        .where((d) => !GuestService.isExpired(
                            (d.data() as Map)['expiresAt'] as Timestamp?))
                        .length;

                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.04),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                            maxWidth: AppConstants.maxMobileWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Add Guest Button
                            GradientButton(
                              text: 'Add New Guest',
                              icon: Icons.person_add,
                              width: double.infinity,
                              height: size.height * 0.07,
                              onPressed: () => _showAddGuestDialog(),
                            ),

                            SizedBox(height: size.height * 0.025),

                            // Quick Duration chips
                            Text('Quick Duration',
                                style: TextStyle(
                                    fontSize: size.width * 0.04,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                            SizedBox(height: size.height * 0.015),
                            Row(
                              children: [
                                _quickChip('6 hours', 6, size),
                                SizedBox(width: size.width * 0.02),
                                _quickChip('24 hours', 24, size),
                                SizedBox(width: size.width * 0.02),
                                _quickChip('7 days', 168, size),
                              ],
                            ),

                            SizedBox(height: size.height * 0.025),

                            // Active Guests header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Active Guests ($activeCount)',
                                    style: TextStyle(
                                        fontSize: size.width * 0.04,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600)),
                                if (sorted.isNotEmpty)
                                  Text('${sorted.length} total',
                                      style: TextStyle(
                                          fontSize: size.width * 0.03,
                                          color: AppColors.textCyanLight)),
                              ],
                            ),
                            SizedBox(height: size.height * 0.015),

                            // Guest list
                            if (sorted.isEmpty)
                              GlassCard(
                                padding: EdgeInsets.all(size.width * 0.08),
                                child: Column(children: [
                                  Icon(Icons.people_outline,
                                      color: AppColors.textCyanLight,
                                      size: size.width * 0.12),
                                  SizedBox(height: size.height * 0.015),
                                  Text('No guests added yet.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: AppColors.textCyanLight,
                                          fontSize: size.width * 0.04,
                                          fontWeight: FontWeight.w500)),
                                  SizedBox(height: size.height * 0.008),
                                  Text(
                                      'Tap "Add New Guest" to grant temporary access.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: AppColors.textCyanLighter,
                                          fontSize: size.width * 0.03)),
                                ]),
                              )
                            else
                              ...sorted.map((doc) =>
                                  _buildGuestCard(doc, size)),

                            SizedBox(height: size.height * 0.025),

                            // Security reminder
                            GlassCard(
                              padding: EdgeInsets.all(size.width * 0.04),
                              borderColor: AppColors.yellow.withOpacity(0.2),
                              backgroundColor:
                                  AppColors.yellow.withOpacity(0.1),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.security,
                                      color: AppColors.yellow, size: 18),
                                  SizedBox(width: size.width * 0.03),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Security Reminder',
                                            style: TextStyle(
                                                fontSize: size.width * 0.035,
                                                color: AppColors.yellow,
                                                fontWeight: FontWeight.w600)),
                                        SizedBox(height: size.height * 0.005),
                                        Text(
                                          'Guest access is temporary and stored securely. Access automatically expires after the set duration.',
                                          style: TextStyle(
                                              fontSize: size.width * 0.03,
                                              color: AppColors.textCyanLighter),
                                        ),
                                      ],
                                    ),
                                  ),
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

  Widget _quickChip(String label, int hours, Size size) {
    return Expanded(
      child: GlassCard(
        padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
        onTap: () => _showAddGuestDialog(presetHours: hours),
        child: Center(
          child: Text(label,
              style: TextStyle(
                  color: AppColors.cyan, fontSize: size.width * 0.03)),
        ),
      ),
    );
  }

  Widget _buildGuestCard(DocumentSnapshot doc, Size size) {
    final data = doc.data() as Map<String, dynamic>;
    final name = data['name'] as String? ?? 'Guest';
    final contact = data['contact'] as String? ?? '';
    final type = data['type'] as String? ?? 'PIN';
    final expiresAt = data['expiresAt'] as Timestamp?;
    final expired = GuestService.isExpired(expiresAt);
    final accessCode = data['accessCode'] as String?;
    final createdAt = data['createdAt'] as Timestamp?;

    return Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.015),
      child: GlassCard(
        padding: EdgeInsets.all(size.width * 0.04),
        borderColor: expired
            ? AppColors.red.withOpacity(0.3)
            : AppColors.cardBorder,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: avatar + info + delete
            Row(children: [
              Container(
                width: size.width * 0.12,
                height: size.width * 0.12,
                decoration: BoxDecoration(
                  color: expired
                      ? AppColors.red.withOpacity(0.1)
                      : AppColors.cyan.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: expired
                          ? AppColors.red.withOpacity(0.3)
                          : AppColors.cyan.withOpacity(0.3)),
                ),
                child: Icon(
                  type == 'QR Code'
                      ? Icons.qr_code_scanner
                      : Icons.vpn_key,
                  size: size.width * 0.06,
                  color: expired ? AppColors.red : AppColors.cyan,
                ),
              ),
              SizedBox(width: size.width * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: TextStyle(
                            fontSize: size.width * 0.04,
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
                    if (contact.isNotEmpty)
                      Text(contact,
                          style: TextStyle(
                              fontSize: size.width * 0.03,
                              color: AppColors.cyan)),
                    Text('Access: $type',
                        style: TextStyle(
                            fontSize: size.width * 0.03,
                            color: AppColors.textCyanLight)),
                    if (createdAt != null)
                      Text(
                        'Added: ${DateFormat('MMM dd, hh:mm a').format(createdAt.toDate())}',
                        style: TextStyle(
                            fontSize: size.width * 0.028,
                            color: AppColors.textCyanLighter),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline,
                    color: expired ? Colors.grey : AppColors.red),
                onPressed: () => _deleteGuest(doc.id, name),
              ),
            ]),

            SizedBox(height: size.height * 0.012),

            // Status row: remaining time badge + view code button
            Row(
              children: [
                _CountdownBadge(expiresAt: expiresAt, size: size),
                const Spacer(),
                if (accessCode != null && !expired)
                  TextButton.icon(
                    onPressed: () => _showGeneratedCode(
                      type: type,
                      code: accessCode,
                      name: name,
                      expiresAt: expiresAt!.toDate(),
                    ),
                    icon: Icon(
                        type == 'QR Code' ? Icons.qr_code : Icons.pin,
                        size: 14,
                        color: AppColors.cyan),
                    label: Text('View Code',
                        style: TextStyle(
                            color: AppColors.cyan,
                            fontSize: size.width * 0.03)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Isolated countdown — only this widget rebuilds every second ───────────────
class _CountdownBadge extends StatefulWidget {
  final Timestamp? expiresAt;
  final Size size;
  const _CountdownBadge({required this.expiresAt, required this.size});

  @override
  State<_CountdownBadge> createState() => _CountdownBadgeState();
}

class _CountdownBadgeState extends State<_CountdownBadge> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expired = GuestService.isExpired(widget.expiresAt);
    final remaining = GuestService.remainingTime(widget.expiresAt);
    final color = expired ? AppColors.red : AppColors.green;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: widget.size.width * 0.03,
          vertical: widget.size.height * 0.006),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: widget.size.width * 0.015,
          height: widget.size.width * 0.015,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: widget.size.width * 0.015),
        Text(remaining,
            style: TextStyle(
                fontSize: widget.size.width * 0.03,
                color: color,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
