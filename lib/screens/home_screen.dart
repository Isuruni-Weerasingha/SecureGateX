import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_glass_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/icon_button_custom.dart';
import '../services/door_service.dart';

// Enables mouse/stylus drag on PageView (critical for Flutter web)
class _DragScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}

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
  final _pageController = PageController(viewportFraction: 0.88);

  // Store doors in state via a StreamSubscription rather than StreamBuilder.
  // This keeps the PageView widget alive on Firestore updates — only the card
  // content re-renders, preserving scroll position and gesture state.
  StreamSubscription<QuerySnapshot>? _doorsSub;
  List<QueryDocumentSnapshot> _doors = [];
  bool _doorsLoading = true;

  int _activePage = 0;
  final Set<String> _loadingDoors = {};

  String get _displayName {
    final user = FirebaseAuth.instance.currentUser;
    return user?.displayName ?? user?.email ?? widget.userName;
  }

  @override
  void initState() {
    super.initState();
    _doorService.seedDoorsIfEmpty();
    _doorsSub = _doorService.watchDoors().listen((snap) {
      if (!mounted) return;
      final sorted = [...snap.docs]..sort((a, b) {
          final aId = (a.data() as Map)['doorId'] as String? ?? '';
          final bId = (b.data() as Map)['doorId'] as String? ?? '';
          return aId.compareTo(bId);
        });
      setState(() {
        _doors = sorted;
        _doorsLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _doorsSub?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _toggleDoor(String docId, String doorName, bool lock) async {
    setState(() => _loadingDoors.add(docId));
    try {
      if (lock) {
        await _doorService.lockDoor(docId, doorName);
      } else {
        await _doorService.unlockDoor(docId, doorName);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to ${lock ? 'lock' : 'unlock'} $doorName'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _loadingDoors.remove(docId));
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
    final carouselHeight = (size.height * 0.38).clamp(260.0, 340.0);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header + "My Doors" label ────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(hPad, hPad, hPad, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
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
                                  color: AppColors.red,
                                  shape: BoxShape.circle),
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
                    SizedBox(height: size.height * 0.022),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('My Doors',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                        Text('${_doors.length} door${_doors.length == 1 ? '' : 's'}',
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textCyanLight)),
                      ],
                    ),
                    SizedBox(height: size.height * 0.012),
                  ],
                ),
              ),

              // ── Door Carousel ────────────────────────────────────────────
              // PageView is a direct child of the outer Column — NOT inside
              // any scroll container, so swipe gestures are never intercepted.
              if (_doorsLoading)
                SizedBox(
                  height: carouselHeight,
                  child: const Center(
                      child: CircularProgressIndicator(color: AppColors.cyan)),
                )
              else ...[
                SizedBox(
                  height: carouselHeight,
                  child: PageView.builder(
                    // Stable key: prevents widget recreation across setState calls
                    key: const PageStorageKey('door_carousel'),
                    controller: _pageController,
                    scrollBehavior: _DragScrollBehavior(),
                    physics: const PageScrollPhysics(),
                    itemCount: _doors.length,
                    onPageChanged: (i) => setState(() => _activePage = i),
                    itemBuilder: (ctx, i) {
                      final doc = _doors[i];
                      final data = doc.data() as Map<String, dynamic>;
                      return _buildDoorCard(
                          doc.id, data, size, i == _activePage);
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Dot indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_doors.length, (i) {
                    final active = i == _activePage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 20 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color:
                            active ? AppColors.cyan : AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ],

              // ── Scrollable content below carousel ────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Auth Methods
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

                      const SizedBox(height: 20),

                      // Guest Access
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
                                  color: AppColors.indigo
                                      .withValues(alpha: 0.4)),
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

                      const SizedBox(height: 20),

                      // Recent Activity
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Recent Activity',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                          TextButton(
                            onPressed: () =>
                                widget.onNavigate('activity-log'),
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
                                                  color: AppColors
                                                      .textCyanLight,
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
                                              color:
                                                  AppColors.textCyanLight,
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

  Widget _buildDoorCard(
      String docId, Map<String, dynamic> data, Size size, bool isActive) {
    final name = data['name'] as String? ?? 'Door';
    final location = data['location'] as String? ?? '';
    final isLocked = data['isLocked'] as bool? ?? true;
    final isLoading = _loadingDoors.contains(docId);
    final statusColor = isLocked ? AppColors.red : AppColors.green;
    final iconSize = (size.width * 0.22).clamp(64.0, 110.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(
          horizontal: size.width * 0.02, vertical: isActive ? 0 : 12),
      child: GradientGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        glowColor: isActive ? statusColor : Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Name + status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontSize: 17,
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                      if (location.isNotEmpty)
                        Text(location,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textCyanLight)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: statusColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    isLocked ? 'Locked' : 'Unlocked',
                    style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),

            // Lock icon + label — Expanded so it fills remaining space
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: statusColor.withValues(alpha: 0.3),
                          width: 2),
                    ),
                    child: Icon(
                      isLocked ? Icons.lock : Icons.lock_open,
                      size: iconSize * 0.46,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isLocked ? 'Door is Locked' : 'Door is Unlocked',
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Buttons — always visible at bottom
            const SizedBox(height: 12),
            if (isLoading)
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
                    onPressed: isLocked
                        ? () => _toggleDoor(docId, name, false)
                        : null,
                    backgroundColor: AppColors.green.withValues(alpha: 0.2),
                    borderColor: AppColors.green.withValues(alpha: 0.3),
                    textColor: AppColors.green,
                    isOutlined: true,
                    height: 44,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomButton(
                    text: 'Lock',
                    icon: Icons.lock,
                    onPressed: !isLocked
                        ? () => _toggleDoor(docId, name, true)
                        : null,
                    backgroundColor: AppColors.red.withValues(alpha: 0.2),
                    borderColor: AppColors.red.withValues(alpha: 0.3),
                    textColor: AppColors.red,
                    isOutlined: true,
                    height: 44,
                  ),
                ),
              ]),
          ],
        ),
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
