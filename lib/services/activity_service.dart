import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/activity_log_model.dart';

class ActivityService {
  final _db = FirebaseFirestore.instance;

  //  Map Firestore doc → ActivityLogModel 
  ActivityLogModel _fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final action = d['action'] as String? ?? 'unknown';
    return ActivityLogModel(
      id: doc.id,
      type: action == 'unlock'
          ? ActivityType.unlock
          : action == 'guest'
              ? ActivityType.guest
              : action == 'failed'
                  ? ActivityType.failed
                  : ActivityType.lock,
      action: action == 'unlock'
          ? 'Door Unlocked'
          : action == 'guest'
              ? 'Guest Access'
              : action == 'failed'
                  ? 'Failed Attempt'
                  : 'Door Locked',
      user: d['userName'] as String? ?? 'User',
      timestamp: (d['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      method: d['method'] as String? ?? 'App',
    );
  }

  //  All logs ordered by newest first 
  Future<List<ActivityLogModel>> getActivities() async {
    final snap = await _db
        .collection('door_logs')
        .orderBy('timestamp', descending: true)
        .get();
    return snap.docs.map(_fromDoc).toList();
  }

  //  Last N logs 
  Future<List<ActivityLogModel>> getRecentActivities(int limit) async {
    final snap = await _db
        .collection('door_logs')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map(_fromDoc).toList();
  }

  // Stats: count per action type 
  Future<Map<String, int>> getActivityStats() async {
    final snap = await _db.collection('door_logs').get();
    int unlocks = 0, locks = 0, failed = 0, guest = 0;
    for (final doc in snap.docs) {
      final action = (doc.data()['action'] as String?) ?? '';
      if (action == 'unlock') unlocks++;
      else if (action == 'lock') locks++;
      else if (action == 'failed') failed++;
      else if (action == 'guest') guest++;
    }
    return {
      'unlocks': unlocks,
      'locks': locks,
      'failed': failed,
      'guest': guest,
      'total': snap.docs.length,
    };
  }

  //  Real-time stream for live updates 
  Stream<List<ActivityLogModel>> watchActivities() {
    return _db
        .collection('door_logs')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  //  Log a failed access attempt 
  Future<void> logFailedAttempt(String method) async {
    final user = FirebaseAuth.instance.currentUser;
    await _db.collection('door_logs').add({
      'userId': user?.uid ?? 'unknown',
      'userName': user?.displayName ?? 'Unknown',
      'action': 'failed',
      'method': method,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
