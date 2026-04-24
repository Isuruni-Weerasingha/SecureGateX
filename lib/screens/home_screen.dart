import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_glass_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/icon_button_custom.dart';
import '../services/door_service.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final Function(String screen) onNavigate;

  const HomeScreen({
    super.key,
    required this.userName,
    required this.onNavigate,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _doorService = DoorService();

  StreamSubscription<QuerySnapshot>? _doorSub;
  QueryDocumentSnapshot? _door;
  bool _doorLoading = true;
  bool _isToggling = false;

  String get _displayName {
    final user = FirebaseAuth.instance.currentUser;
    return user?.displayName ?? user?.email ?? widget.userName;
  }

  @override
  void initState() {
    super.initState();
    _doorService.seedDoorsIfEmpty();
    _doorSub = _doorService.watchDoors().listen((snap) {
      if (!mounted) return;
      // Sort and take the first door
      final docs = [...snap.docs]..sort((a, b) {
          final aId = (a.data() as Map)['doorId'] as String? ?? '';
          final bId = (b.data() as Map)['doorId'] as String? ?? '';
          return aId.compareTo(bId);
        });
      setState(() {
        _door = docs.isNotEmpty ? docs.first : null;
        _doorLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _doorSub?.cancel();
    super.dispose();
  }

  Future<void> _toggleDoor(bool lock) async {
    if (_door == null) return;
    final data = _door!.data() as Map<String, dynamic>;
    final name = data['name'] as String? ?? 'Door';

    setState(() => _isToggling = true);
    try {
      if (lock) {
        await _doorService.lockDoor(_door!.id, name);
      } else {
        await _doorService.unlockDoor(_door!.id, name);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to ${lock ? 'lock' : 'unlock'} $name'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _isToggling = false);
    }
  }

  IconData _actionIcon(String action) =>
      action == 'unlock' ? Icons.lock_open : Icons.lock;

  Color _actionColor(String action) =>
      action == 'unlock' ? AppColors.green : AppColors.blue;

  String _relativeTime(Timestamp? ts) {
    if (ts == null) return '...';
    final diff = DateTime.now().difference(ts.toDate());
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final hPad = size.width * 0.04;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ───────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(hPad, hPad, hPad, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome back,',
                              style: TextStyle(
                                  fontSize: size.width * 0.05,
                                  color: Colors.white)),
                          Text(_displayName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: size.width * 0.045,
                                  color: AppColors.cyan,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Row(children: [
                      IconButtonCustom(
                        icon: Icons.notifications_outlined,
                        onPressed: () => widget.onNavigate('notifications'),
                        badge: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: AppColors.red, shape: BoxShape.circle),
                        ),
                      ),
                      SizedBox(width: size.width * 0.02),
                      IconButtonCustom(
                        icon: Icons.menu,
                        onPressed: () => widget.onNavigate('profile'),
                      ),
                    ]),
                  ],
                ),
              ),

              // ── Scrollable body ──────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(hPad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: size.height * 0.01),

                      // ── Door Card ────────────────────────────────────────
                      _buildDoorCard(size),

                      SizedBox(height: size.height * 0.03),

                      // ── Authentication Methods ────────────────────────────
                      const Text('Authentication Methods',
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                            child: _authCard(
                                icon: Icons.fingerprint,
                                label: 'Fingerprint',
                                onTap: () => widget
                                    .onNavigate('fingerprint-settings'))),
                        SizedBox(width: size.width * 0.03),
                        Expanded(
                            child: _authCard(
                                icon: Icons.qr_code_scanner,
                                label: 'QR Code',
                                onTap: () => widget.onNavigate('qr-scan'))),
                        SizedBox(width: size.width * 0.03),
                        Expanded(
                            child: _authCard(
                                icon: Icons.vpn_key,
                                label: 'PIN',
                                onTap: () =>
                                    widget.onNavigate('auth-selection'))),
                      ]),

                      SizedBox(height: size.height * 0.03),

                      // ── Guest Access ─────────────────────────────────────
                      GlassCard(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.05, vertical: 16),
                        onTap: () => widget.onNavigate('guest-access'),
                        child: Row(children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppColors.indigo.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color:
                                      AppColors.indigo.withValues(alpha: 0.4)),
                            ),
                            child: const Icon(Icons.people_outline,
                                size: 24, color: AppColors.indigo),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Guest Access',
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600)),
                                SizedBox(height: 2),
                                Text('Manage temporary guest access',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textCyanLight)),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios,
                              size: 14, color: AppColors.textCyanLight),
                        ]),
                      ),

                      SizedBox(height: size.height * 0.03),

                      // ── Recent Activity ──────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Recent Activity',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                          TextButton(
                            onPressed: () => widget.onNavigate('activity-log'),
                            child: const Text('View All',
                                style: TextStyle(
                                    color: AppColors.cyan, fontSize: 13)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      StreamBuilder<QuerySnapshot>(
                        stream: _doorService.getDoorLogsStream(limit: 3),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(
                                  color: AppColors.cyan),
                            ));
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return GlassCard(
                              padding: const EdgeInsets.all(16),
                              child: const Text('No activity yet.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: AppColors.textCyanLight,
                                      fontSize: 13)),
                            );
                          }
                          return Column(
                            children: snapshot.data!.docs.map((doc) {
                              final data =
                                  doc.data() as Map<String, dynamic>;
                              final action =
                                  data['action'] as String? ?? 'unknown';
                              final userName =
                                  data['userName'] as String? ?? 'User';
                              final doorName =
                                  data['doorName'] as String? ?? 'Door';
                              final ts = data['timestamp'] as Timestamp?;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: GlassCard(
                                  padding: const EdgeInsets.all(14),
                                  child: Row(children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: _actionColor(action)
                                            .withValues(alpha: 0.2),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        border: Border.all(
                                            color: _actionColor(action)
                                                .withValues(alpha: 0.3)),
                                      ),
                                      child: Icon(_actionIcon(action),
                                          size: 18,
                                          color: _actionColor(action)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$doorName ${action == 'unlock' ? 'Unlocked' : 'Locked'}',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight:
                                                    FontWeight.w500),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(userName,
                                              style: const TextStyle(
                                                  color:
                                                      AppColors.textCyanLight,
                                                  fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    Row(children: [
                                      const Icon(Icons.access_time,
                                          size: 11,
                                          color: AppColors.textCyanLight),
                                      const SizedBox(width: 4),
                                      Text(_relativeTime(ts),
                                          style: const TextStyle(
                                              color: AppColors.textCyanLight,
                                              fontSize: 11)),
                                    ]),
                                  ]),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoorCard(Size size) {
    if (_doorLoading) {
      return SizedBox(
        height: 260,
        child: GradientGlassCard(
          padding: const EdgeInsets.all(24),
          glowColor: AppColors.cyan,
          child: const Center(
              child: CircularProgressIndicator(color: AppColors.cyan)),
        ),
      );
    }

    if (_door == null) {
      return GradientGlassCard(
        padding: const EdgeInsets.all(24),
        glowColor: AppColors.red,
        child: const Center(
          child: Text('No door found.',
              style: TextStyle(color: AppColors.textCyanLight)),
        ),
      );
    }

    final data = _door!.data() as Map<String, dynamic>;
    final name = data['name'] as String? ?? 'Front Door';
    final location = data['location'] as String? ?? '';
    final isLocked = data['isLocked'] as bool? ?? true;
    final statusColor = isLocked ? AppColors.red : AppColors.green;
    final iconSize = (size.width * 0.28).clamp(80.0, 130.0);

    return GradientGlassCard(
      padding: EdgeInsets.all(size.width * 0.06),
      glowColor: statusColor,
      child: Column(
        children: [
          // ── Name + status badge ─────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: TextStyle(
                            fontSize: size.width * 0.05,
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
                    if (location.isNotEmpty)
                      Text(location,
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textCyanLight)),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  isLocked ? 'Locked' : 'Unlocked',
                  style: TextStyle(
                      fontSize: 13,
                      color: statusColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),

          SizedBox(height: size.height * 0.03),

          // ── Lock icon ───────────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                  color: statusColor.withValues(alpha: 0.3), width: 2),
            ),
            child: Icon(
              isLocked ? Icons.lock : Icons.lock_open,
              size: iconSize * 0.46,
              color: statusColor,
            ),
          ),

          SizedBox(height: size.height * 0.025),

          Text(
            isLocked ? 'Door is Locked' : 'Door is Unlocked',
            style: TextStyle(
                fontSize: size.width * 0.055,
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),

          SizedBox(height: size.height * 0.025),

          // ── Lock / Unlock buttons ───────────────────────────────────
          if (_isToggling)
            const LinearProgressIndicator(
                color: AppColors.cyan,
                backgroundColor: AppColors.cardBackground,
                minHeight: 3)
          else
            Row(children: [
              Expanded(
                child: CustomButton(
                  text: 'Unlock',
                  icon: Icons.lock_open,
                  onPressed: isLocked ? () => _toggleDoor(false) : null,
                  backgroundColor: AppColors.green.withValues(alpha: 0.2),
                  borderColor: AppColors.green.withValues(alpha: 0.3),
                  textColor: AppColors.green,
                  isOutlined: true,
                  height: size.height * 0.06,
                ),
              ),
              SizedBox(width: size.width * 0.04),
              Expanded(
                child: CustomButton(
                  text: 'Lock',
                  icon: Icons.lock,
                  onPressed: !isLocked ? () => _toggleDoor(true) : null,
                  backgroundColor: AppColors.red.withValues(alpha: 0.2),
                  borderColor: AppColors.red.withValues(alpha: 0.3),
                  textColor: AppColors.red,
                  isOutlined: true,
                  height: size.height * 0.06,
                ),
              ),
            ]),
        ],
      ),
    );
  }

  Widget _authCard(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: AppColors.cyan),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textCyanLight, fontSize: 11)),
        ],
      ),
    );
  }
}
