import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_glass_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/back_button_custom.dart';

class SmartContractStatusScreen extends StatefulWidget {
  final VoidCallback onBack;
  const SmartContractStatusScreen({super.key, required this.onBack});

  @override
  State<SmartContractStatusScreen> createState() =>
      _SmartContractStatusScreenState();
}

class _SmartContractStatusScreenState
    extends State<SmartContractStatusScreen> {
  final _db = FirebaseFirestore.instance;

  Map<String, dynamic>? _config;
  Map<String, dynamic>? _latestLog;
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isConnected = false;

  StreamSubscription<QuerySnapshot>? _logSub;

  @override
  void initState() {
    super.initState();
    _loadConfig();
    _subscribeToLogs();
  }

  @override
  void dispose() {
    _logSub?.cancel();
    super.dispose();
  }

  Future<void> _loadConfig({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() => _isRefreshing = true);
    }
    try {
      final doc =
          await _db.collection('smart_contract').doc('config').get();
      if (mounted) {
        setState(() {
          _config = doc.data();
          _isConnected = doc.exists;
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
          _isConnected = false;
        });
      }
    }
  }

  void _subscribeToLogs() {
    _logSub = _db
        .collection('door_logs')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((snap) {
      if (!mounted) return;
      setState(() {
        _latestLog =
            snap.docs.isNotEmpty ? snap.docs.first.data() : null;
      });
    });
  }

  String _fmtTimestamp(dynamic value) {
    if (value == null) return '—';
    DateTime dt;
    if (value is Timestamp) {
      dt = value.toDate();
    } else {
      return value.toString();
    }
    return DateFormat('MMM d, yyyy h:mm a').format(dt);
  }

  String _truncate(String? value, {int length = 20}) {
    if (value == null || value.isEmpty) return '—';
    if (value.length <= length * 2 + 3) return value;
    return '${value.substring(0, length)}...${value.substring(value.length - 6)}';
  }

  void _copy(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$label copied to clipboard'),
      backgroundColor: AppColors.cyan,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _config ?? {};
    final log = _latestLog ?? {};

    final contractAddress =
        cfg['contractAddress'] as String? ?? '—';
    final network = cfg['network'] as String? ?? 'Ethereum Testnet';
    final chainId = cfg['chainId']?.toString() ?? '—';
    final blockHeight = cfg['blockHeight']?.toString() ?? '—';
    final contractVersion =
        cfg['contractVersion'] as String? ?? '—';
    final deployedOn = _fmtTimestamp(cfg['deployedOn']);

    final txHash = log['txHash'] as String? ?? log['action'] as String? ?? '—';
    final txTimestamp = _fmtTimestamp(log['timestamp']);
    final gasUsed = log['gasUsed']?.toString() ?? '—';
    final txStatus = log['status'] as String? ?? 'Confirmed';

    final statusColor = _isConnected ? AppColors.green : AppColors.red;
    final statusLabel = _isConnected ? 'Connected' : 'Disconnected';
    final statusSub = _isConnected
        ? 'Blockchain is active'
        : 'Cannot reach blockchain';

    return Scaffold(
      body: Container(
        decoration:
            const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    BackButtonCustom(onPressed: widget.onBack),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Smart Contract',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        Text('Blockchain status',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textCyanLight)),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Refresh progress bar ─────────────────────────────────
              if (_isRefreshing)
                const LinearProgressIndicator(
                  color: AppColors.cyan,
                  backgroundColor: Colors.transparent,
                  minHeight: 2,
                ),

              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.cyan),
                      )
                    : SingleChildScrollView(
                        padding:
                            const EdgeInsets.all(AppConstants.spacingMD),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                                maxWidth: AppConstants.maxMobileWidth),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                              children: [
                                // ── Connection status card ───────────────
                                GradientGlassCard(
                                  padding: const EdgeInsets.all(24),
                                  glowColor: statusColor,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 64,
                                        height: 64,
                                        decoration: BoxDecoration(
                                          color: statusColor
                                              .withValues(alpha: 0.2),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color: statusColor
                                                .withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Icon(
                                          _isConnected
                                              ? Icons.check_circle
                                              : Icons.error_outline,
                                          size: 32,
                                          color: statusColor,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(statusLabel,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: statusColor,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(statusSub,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: statusColor
                                                        .withValues(
                                                            alpha: 0.7))),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: BoxDecoration(
                                                    color: statusColor,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  _isConnected
                                                      ? 'All systems operational'
                                                      : 'Check Firestore config',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: statusColor
                                                          .withValues(
                                                              alpha: 0.7)),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // ── Network info card ────────────────────
                                GlassCard(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _cardHeader(
                                        icon: Icons.account_tree,
                                        color: AppColors.purple,
                                        title: 'Blockchain Network',
                                        subtitle: 'Current network status',
                                      ),
                                      const SizedBox(height: 16),
                                      _infoRow('Network', network,
                                          isHighlight: true),
                                      _infoRow('Chain ID', chainId),
                                      _infoRow('Block Height', blockHeight),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // ── Contract address card ────────────────
                                GlassCard(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _cardHeader(
                                        icon: Icons.shield,
                                        color: AppColors.blue,
                                        title: 'Smart Contract Address',
                                        subtitle: 'Deployed contract',
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: AppColors.slate950
                                              .withValues(alpha: 0.5),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: AppColors.cardBorder
                                                .withValues(alpha: 0.5),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              contractAddress == '—'
                                                  ? '—'
                                                  : _truncate(
                                                      contractAddress,
                                                      length: 16),
                                              style: const TextStyle(
                                                color: AppColors.cyan,
                                                fontSize: 12,
                                                fontFamily: 'monospace',
                                              ),
                                            ),
                                            if (contractAddress != '—') ...[
                                              const SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: CustomButton(
                                                      text: 'Copy',
                                                      icon: Icons.copy,
                                                      onPressed: () => _copy(
                                                          contractAddress,
                                                          'Address'),
                                                      backgroundColor:
                                                          AppColors.cyan
                                                              .withValues(
                                                                  alpha: 0.2),
                                                      borderColor:
                                                          AppColors.cyan
                                                              .withValues(
                                                                  alpha: 0.3),
                                                      textColor: AppColors.cyan,
                                                      isOutlined: true,
                                                      height: 36,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: CustomButton(
                                                      text: 'Explorer',
                                                      icon: Icons.open_in_new,
                                                      onPressed: () {},
                                                      backgroundColor:
                                                          AppColors.blue
                                                              .withValues(
                                                                  alpha: 0.2),
                                                      borderColor:
                                                          AppColors.blue
                                                              .withValues(
                                                                  alpha: 0.3),
                                                      textColor: AppColors.blue,
                                                      isOutlined: true,
                                                      height: 36,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      _infoRow('Contract Version',
                                          contractVersion),
                                      _infoRow('Deployed On', deployedOn),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // ── Last transaction card ────────────────
                                GlassCard(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Last Transaction',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 16),
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: AppColors.slate950
                                              .withValues(alpha: 0.5),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: AppColors.cardBorder
                                                .withValues(alpha: 0.5),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Transaction Hash',
                                                style: TextStyle(
                                                    color: AppColors
                                                        .textCyanLighter,
                                                    fontSize: 12)),
                                            const SizedBox(height: 8),
                                            Text(
                                              _truncate(txHash, length: 18),
                                              style: const TextStyle(
                                                color: AppColors.cyan,
                                                fontSize: 12,
                                                fontFamily: 'monospace',
                                              ),
                                            ),
                                            if (txHash != '—') ...[
                                              const SizedBox(height: 12),
                                              CustomButton(
                                                text: 'Copy Hash',
                                                icon: Icons.copy,
                                                onPressed: () =>
                                                    _copy(txHash, 'Hash'),
                                                backgroundColor:
                                                    AppColors.cyan
                                                        .withValues(alpha: 0.2),
                                                borderColor: AppColors.cyan
                                                    .withValues(alpha: 0.3),
                                                textColor: AppColors.cyan,
                                                isOutlined: true,
                                                width: double.infinity,
                                                height: 36,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      _infoRow('Timestamp', txTimestamp),
                                      _infoRow('Gas Used', gasUsed),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 4),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Status',
                                                style: TextStyle(
                                                    color: AppColors
                                                        .textCyanLight,
                                                    fontSize: 14)),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                              decoration: BoxDecoration(
                                                color: AppColors.green
                                                    .withValues(alpha: 0.2),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: AppColors.green
                                                      .withValues(alpha: 0.3),
                                                ),
                                              ),
                                              child: Text(
                                                txStatus,
                                                style: const TextStyle(
                                                    color: AppColors.green,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // ── Refresh button ───────────────────────
                                GradientButton(
                                  text: _isRefreshing
                                      ? 'Refreshing...'
                                      : 'Refresh Status',
                                  onPressed: _isRefreshing
                                      ? null
                                      : () => _loadConfig(isRefresh: true),
                                  width: double.infinity,
                                  height: 48,
                                ),

                                const SizedBox(height: 24),
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

  Widget _cardHeader({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, size: 24, color: color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600)),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textCyanLight)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textCyanLight, fontSize: 14)),
          if (isHighlight)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.cyan.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.cyan.withValues(alpha: 0.3)),
              ),
              child: Text(value,
                  style: const TextStyle(
                      color: AppColors.cyan,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            )
          else
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'monospace')),
        ],
      ),
    );
  }
}
