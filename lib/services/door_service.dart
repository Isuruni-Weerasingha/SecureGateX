import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_service.dart';

class DoorService {
  final _db = FirebaseFirestore.instance;
  final _notifService = NotificationService();

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
  String get _userName =>
      FirebaseAuth.instance.currentUser?.displayName ?? 'User';

  CollectionReference get _doorsCol => _db.collection('doors');

  static const _defaultDoors = [
    {'id': 'front_door_1', 'name': 'Front Door 1', 'location': 'Main Entrance'},
    {'id': 'front_door_2', 'name': 'Front Door 2', 'location': 'Side Entrance'},
    {'id': 'back_door',    'name': 'Back Door',    'location': 'Rear Exit'},
  ];

  // ── Seed doors for user if not yet created ────────────────────────────────
  Future<void> seedDoorsIfEmpty() async {
    final snap = await _doorsCol
        .where('userId', isEqualTo: _uid)
        .limit(1)
        .get();
    if (snap.docs.isNotEmpty) return;

    final batch = _db.batch();
    for (final d in _defaultDoors) {
      batch.set(_doorsCol.doc('${_uid}_${d['id']}'), {
        'userId': _uid,
        'doorId': d['id'],
        'name': d['name'],
        'location': d['location'],
        'isLocked': true,
        'lastChanged': FieldValue.serverTimestamp(),
        'changedBy': _userName,
      });
    }
    await batch.commit();
  }

  // ── Real-time stream of all doors for current user ────────────────────────
  Stream<QuerySnapshot> watchDoors() {
    return _doorsCol
        .where('userId', isEqualTo: _uid)
        .snapshots();
  }

  // ── Lock a door — docId/doorName optional; defaults to front_door_1 ───────
  Future<void> lockDoor([String? docId, String? doorName]) async {
    final id = docId ?? '${_uid}_front_door_1';
    final name = doorName ?? 'Front Door 1';
    await _doorsCol.doc(id).update({
      'isLocked': true,
      'lastChanged': FieldValue.serverTimestamp(),
      'changedBy': _userName,
    });
    await _logAction('lock', name);
    await _notifService.push(
      title: 'Door Locked',
      message: '$_userName locked $name.',
      type: 'success',
    );
  }

  // ── Unlock a door — docId/doorName optional; defaults to front_door_1 ─────
  Future<void> unlockDoor([String? docId, String? doorName]) async {
    final id = docId ?? '${_uid}_front_door_1';
    final name = doorName ?? 'Front Door 1';
    await _doorsCol.doc(id).update({
      'isLocked': false,
      'lastChanged': FieldValue.serverTimestamp(),
      'changedBy': _userName,
    });
    await _logAction('unlock', name);
    await _notifService.push(
      title: 'Door Unlocked',
      message: '$_userName unlocked $name.',
      type: 'success',
    );
  }

  // ── Log action to door_logs ───────────────────────────────────────────────
  Future<void> _logAction(String action, String doorName) async {
    await _db.collection('door_logs').add({
      'userId': _uid,
      'userName': _userName,
      'doorName': doorName,
      'action': action,
      'method': 'App',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // ── Real-time stream of door_logs ─────────────────────────────────────────
  Stream<QuerySnapshot> getDoorLogsStream({int limit = 3}) {
    return _db
        .collection('door_logs')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots();
  }
}
