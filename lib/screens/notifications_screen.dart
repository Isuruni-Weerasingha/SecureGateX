import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/back_button_custom.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  final VoidCallback onBack;
  const NotificationsScreen({super.key, required this.onBack});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _svc = NotificationService();

  @override
  void initState() {
    super.initState();
    _svc.seedIfEmpty();
  }

  Color _color(String type) => switch (type) {
        'warning' => AppColors.red,
        'success' => AppColors.green,
        'info'    => AppColors.blue,
        _         => AppColors.cyan,
      };

  IconData _icon(String type) => switch (type) {
        'warning' => Icons.warning_amber_rounded,
        'success' => Icons.check_circle,
        'info'    => Icons.person_add,
        _         => Icons.notifications,
      };

  String _timeAgo(Timestamp? ts) {
    if (ts == null) return 'Just now';
    final diff = DateTime.now().difference(ts.toDate());
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Future<void> _addTestNotification() async {
    await _svc.push(
      title: 'Test Notification',
      message: 'This is a test notification added at ${TimeOfDay.now().format(context)}.',
      type: 'info',
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      BackButtonCustom(onPressed: widget.onBack),
                      SizedBox(width: size.width * 0.04),
                      StreamBuilder<int>(
                        stream: _svc.watchUnreadCount(),
                        builder: (ctx, snap) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Notifications',
                                style: TextStyle(
                                    fontSize: size.width * 0.05,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            Text(
                              (snap.data ?? 0) == 0
                                  ? 'All read'
                                  : '${snap.data} unread',
                              style: TextStyle(
                                  fontSize: size.width * 0.035,
                                  color: AppColors.textCyanLight),
                            ),
                          ],
                        ),
                      ),
                    ]),
                    Row(children: [
                      IconButton(
                        icon: const Icon(Icons.add_alert_outlined,
                            color: AppColors.cyan),
                        tooltip: 'Add test notification',
                        onPressed: _addTestNotification,
                      ),
                      TextButton(
                        onPressed: _svc.markAllRead,
                        child: Text('Mark all read',
                            style: TextStyle(
                                color: AppColors.cyan,
                                fontSize: size.width * 0.032)),
                      ),
                    ]),
                  ],
                ),
              ),

              // ── List ────────────────────────────────────────────────────
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _svc.watchNotifications(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}',
                            style: const TextStyle(color: AppColors.red)),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.cyan));
                    }

                    // Sort client-side by createdAt descending
                    final docs = [...(snapshot.data?.docs ?? [])]..sort((a, b) {
                        final aTs = (a.data() as Map)['createdAt'] as Timestamp?;
                        final bTs = (b.data() as Map)['createdAt'] as Timestamp?;
                        if (aTs == null || bTs == null) return 0;
                        return bTs.compareTo(aTs);
                      });

                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.04),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                            maxWidth: AppConstants.maxMobileWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (docs.isEmpty)
                              GlassCard(
                                padding: EdgeInsets.all(size.width * 0.1),
                                child: Column(children: [
                                  Icon(Icons.notifications_off_outlined,
                                      color: AppColors.textCyanLight,
                                      size: size.width * 0.12),
                                  SizedBox(height: size.height * 0.015),
                                  Text('No notifications yet.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: AppColors.textCyanLight,
                                          fontSize: size.width * 0.04)),
                                  SizedBox(height: size.height * 0.008),
                                  Text(
                                      'Tap + to add a test notification.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: AppColors.textCyanLighter,
                                          fontSize: size.width * 0.03)),
                                ]),
                              )
                            else
                              ...docs.map((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                final type = data['type'] as String? ?? 'info';
                                final isRead = data['read'] as bool? ?? false;
                                final color = _color(type);

                                return Padding(
                                  padding: EdgeInsets.only(
                                      bottom: size.height * 0.015),
                                  child: Stack(children: [
                                    GlassCard(
                                      padding: EdgeInsets.all(size.width * 0.04),
                                      borderColor: color.withOpacity(0.3),
                                      backgroundColor: color.withOpacity(0.08),
                                      onTap: isRead
                                          ? null
                                          : () => _svc.markRead(doc.id),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: size.width * 0.12,
                                            height: size.width * 0.12,
                                            decoration: BoxDecoration(
                                              color: color.withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                  color: color.withOpacity(0.3)),
                                            ),
                                            child: Icon(_icon(type),
                                                size: size.width * 0.06,
                                                color: color),
                                          ),
                                          SizedBox(width: size.width * 0.03),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  data['title'] as String? ?? '',
                                                  style: TextStyle(
                                                      color: color,
                                                      fontSize:
                                                          size.width * 0.038,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                SizedBox(
                                                    height: size.height * 0.005),
                                                Text(
                                                  data['message'] as String? ?? '',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize:
                                                          size.width * 0.035),
                                                ),
                                                SizedBox(
                                                    height: size.height * 0.008),
                                                Text(
                                                  _timeAgo(data['createdAt']
                                                      as Timestamp?),
                                                  style: TextStyle(
                                                      color: AppColors
                                                          .textCyanLighter,
                                                      fontSize:
                                                          size.width * 0.03),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!isRead)
                                      Positioned(
                                        top: size.width * 0.04,
                                        right: size.width * 0.04,
                                        child: const Icon(Icons.circle,
                                            size: 8, color: AppColors.cyan),
                                      ),
                                  ]),
                                );
                              }),

                            SizedBox(height: size.height * 0.015),

                            GlassCard(
                              padding: EdgeInsets.all(size.width * 0.04),
                              onTap: docs.isEmpty ? null : _svc.clearAll,
                              child: Center(
                                child: Text('Clear All Notifications',
                                    style: TextStyle(
                                        color: docs.isEmpty
                                            ? AppColors.textCyanLighter
                                            : AppColors.red,
                                        fontSize: size.width * 0.04,
                                        fontWeight: FontWeight.w600)),
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
}
