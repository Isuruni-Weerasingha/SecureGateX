import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/back_button_custom.dart';
import '../services/activity_service.dart';
import '../models/activity_log_model.dart';

class ActivityLogScreen extends StatelessWidget {
  final VoidCallback onBack;
  const ActivityLogScreen({super.key, required this.onBack});

  IconData _icon(ActivityType t) => switch (t) {
        ActivityType.unlock => Icons.lock_open,
        ActivityType.lock => Icons.lock,
        ActivityType.guest => Icons.person_add,
        ActivityType.failed => Icons.error_outline,
      };

  Color _color(ActivityType t) => switch (t) {
        ActivityType.unlock => AppColors.green,
        ActivityType.lock => AppColors.blue,
        ActivityType.guest => AppColors.cyan,
        ActivityType.failed => AppColors.red,
      };

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final svc = ActivityService();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ────────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.all(size.width * 0.04),
                child: Row(
                  children: [
                    BackButtonCustom(onPressed: onBack),
                    SizedBox(width: size.width * 0.04),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Activity Log',
                            style: TextStyle(
                                fontSize: size.width * 0.05,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        Text('Complete access history',
                            style: TextStyle(
                                fontSize: size.width * 0.035,
                                color: AppColors.textCyanLight)),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Body: StreamBuilder for live updates ──────────────────────
              Expanded(
                child: StreamBuilder<List<ActivityLogModel>>(
                  stream: svc.watchActivities(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(color: AppColors.cyan));
                    }

                    final logs = snapshot.data ?? [];

                    // Compute stats from live data
                    final unlocks =
                        logs.where((l) => l.type == ActivityType.unlock).length;
                    final locks =
                        logs.where((l) => l.type == ActivityType.lock).length;
                    final failed =
                        logs.where((l) => l.type == ActivityType.failed).length;

                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.04),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                            maxWidth: AppConstants.maxMobileWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ── Stats Row ─────────────────────────────────
                            Row(
                              children: [
                                _statCard(size, '$unlocks', 'Unlocks',
                                    AppColors.green),
                                SizedBox(width: size.width * 0.03),
                                _statCard(
                                    size, '$locks', 'Locks', AppColors.blue),
                                SizedBox(width: size.width * 0.03),
                                _statCard(
                                    size, '$failed', 'Failed', AppColors.red),
                              ],
                            ),

                            SizedBox(height: size.height * 0.025),

                            // ── Log List ──────────────────────────────────
                            if (logs.isEmpty)
                              GlassCard(
                                padding: EdgeInsets.all(size.width * 0.06),
                                child: Text(
                                  'No activity yet.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: AppColors.textCyanLight,
                                      fontSize: size.width * 0.035),
                                ),
                              )
                            else
                              ...logs.map((log) => Padding(
                                    padding: EdgeInsets.only(
                                        bottom: size.height * 0.015),
                                    child: GlassCard(
                                      padding:
                                          EdgeInsets.all(size.width * 0.04),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Icon
                                          Container(
                                            width: size.width * 0.12,
                                            height: size.width * 0.12,
                                            decoration: BoxDecoration(
                                              color: _color(log.type)
                                                  .withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                  color: _color(log.type)
                                                      .withOpacity(0.3)),
                                            ),
                                            child: Icon(_icon(log.type),
                                                size: size.width * 0.06,
                                                color: _color(log.type)),
                                          ),
                                          SizedBox(width: size.width * 0.03),
                                          // Details
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(log.action,
                                                    style: TextStyle(
                                                        color: _color(log.type),
                                                        fontSize:
                                                            size.width * 0.038,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                                SizedBox(
                                                    height:
                                                        size.height * 0.004),
                                                Text(log.user,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize:
                                                            size.width * 0.035)),
                                                if (log.method != null)
                                                  Text('Method: ${log.method}',
                                                      style: TextStyle(
                                                          color: AppColors
                                                              .textCyanLight,
                                                          fontSize:
                                                              size.width *
                                                                  0.03)),
                                                SizedBox(
                                                    height:
                                                        size.height * 0.008),
                                                Row(children: [
                                                  Icon(Icons.calendar_today,
                                                      size: size.width * 0.03,
                                                      color: AppColors
                                                          .textCyanLighter),
                                                  SizedBox(
                                                      width:
                                                          size.width * 0.01),
                                                  Text(
                                                    DateFormat('MMM d, yyyy  h:mm a')
                                                        .format(log.timestamp),
                                                    style: TextStyle(
                                                        color: AppColors
                                                            .textCyanLighter,
                                                        fontSize:
                                                            size.width * 0.03),
                                                  ),
                                                ]),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),

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

  Widget _statCard(Size size, String value, String label, Color color) {
    return Expanded(
      child: GlassCard(
        padding: EdgeInsets.all(size.width * 0.04),
        borderColor: color.withOpacity(0.3),
        backgroundColor: color.withOpacity(0.1),
        child: Column(children: [
          Text(value,
              style: TextStyle(
                  fontSize: size.width * 0.06,
                  color: color,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: size.height * 0.005),
          Text(label,
              style: TextStyle(
                  fontSize: size.width * 0.03,
                  color: color.withOpacity(0.7))),
        ]),
      ),
    );
  }
}
