import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GuestService {
  final _db = FirebaseFirestore.instance;
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference get _col => _db.collection('guest_access');

  // ── Real-time stream of all guests for current user ───────────────────────
  Stream<QuerySnapshot> watchGuests() {
    if (_uid == null) return const Stream.empty();
    return _col
        .where('createdBy', isEqualTo: _uid)
        .snapshots();
  }

  // ── Add guest with generated access code ─────────────────────────────────
  Future<void> addGuestWithCode({
    required String name,
    required String contact,
    required String type,
    required String accessCode,
    required DateTime expiresAt,
  }) async {
    if (_uid == null) return;
    final diff = expiresAt.difference(DateTime.now());
    await _col.add({
      'name': name,
      'contact': contact,
      'type': type,
      'accessCode': accessCode,
      'durationHours': diff.inHours,
      'createdBy': _uid,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'isActive': true,
    });
  }

  // ── Add guest (duration-based, no code) ──────────────────────────────────
  Future<void> addGuest({
    required String name,
    required String contact,
    required String type,
    required int durationHours,
  }) async {
    if (_uid == null) return;
    final expiresAt = DateTime.now().add(Duration(hours: durationHours));
    await _col.add({
      'name': name,
      'contact': contact,
      'type': type,
      'durationHours': durationHours,
      'accessCode': null,
      'createdBy': _uid,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'isActive': true,
    });
  }

  // ── Revoke (delete) a guest ───────────────────────────────────────────────
  Future<void> deleteGuest(String docId) async {
    await _col.doc(docId).delete();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  static bool isExpired(Timestamp? expiresAt) {
    if (expiresAt == null) return false;
    return expiresAt.toDate().isBefore(DateTime.now());
  }

  static String remainingTime(Timestamp? expiresAt) {
    if (expiresAt == null) return 'Unknown';
    final exp = expiresAt.toDate();
    final diff = exp.difference(DateTime.now());
    if (diff.isNegative) return 'Expired';
    if (diff.inDays >= 1) return '${diff.inDays}d ${diff.inHours % 24}h remaining';
    if (diff.inHours >= 1) return '${diff.inHours}h ${diff.inMinutes % 60}m remaining';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m remaining';
    return '${diff.inSeconds}s remaining';
  }
}
