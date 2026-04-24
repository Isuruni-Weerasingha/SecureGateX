import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final _db = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;
  CollectionReference get _col => _db.collection('notifications');

  // No orderBy — avoids composite index requirement (sort client-side)
  Stream<QuerySnapshot> watchNotifications() {
    if (_uid == null) return const Stream.empty();
    return _col.where('userId', isEqualTo: _uid).snapshots();
  }

  Stream<int> watchUnreadCount() {
    if (_uid == null) return Stream.value(0);
    return _col.where('userId', isEqualTo: _uid).snapshots().map(
          (snap) => snap.docs
              .where((d) => (d.data() as Map)['read'] == false)
              .length,
        );
  }

  Future<void> markRead(String docId) async {
    await _col.doc(docId).update({'read': true});
  }

  Future<void> markAllRead() async {
    if (_uid == null) return;
    final snap = await _col.where('userId', isEqualTo: _uid).get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      if ((doc.data() as Map)['read'] == false) {
        batch.update(doc.reference, {'read': true});
      }
    }
    await batch.commit();
  }

  Future<void> clearAll() async {
    if (_uid == null) return;
    final snap = await _col.where('userId', isEqualTo: _uid).get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> push({
    required String title,
    required String message,
    required String type,
  }) async {
    if (_uid == null) return;
    await _col.add({
      'userId': _uid,
      'title': title,
      'message': message,
      'type': type,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> seedIfEmpty() async {
    if (_uid == null) return;
    final snap = await _col.where('userId', isEqualTo: _uid).limit(1).get();
    if (snap.docs.isNotEmpty) return;

    final samples = [
      {'title': 'Door Unlocked', 'message': 'Front door was unlocked successfully.', 'type': 'success'},
      {'title': 'Guest Access Granted', 'message': 'Temporary access granted to Sarah Smith for 24 hours.', 'type': 'info'},
      {'title': 'Failed Login Attempt', 'message': 'An unauthorized access attempt was detected.', 'type': 'warning'},
      {'title': 'Door Locked', 'message': 'Front door was locked automatically.', 'type': 'success'},
    ];

    final batch = _db.batch();
    for (final s in samples) {
      batch.set(_col.doc(), {
        'userId': _uid,
        ...s,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }
}
