import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsService {
  final _db = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _db.collection('users').doc(_uid);

  // ── Load settings from Firestore ──────────────────────────────────────────
  Future<Map<String, dynamic>> loadSettings() async {
    final doc = await _userDoc.get();
    final data = doc.data() ?? {};
    return {
      'biometricEnabled': data['biometricEnabled'] ?? true,
      'darkMode': data['darkMode'] ?? true,
      'network': data['network'] ?? 'testnet',
      'notificationsEnabled': data['notificationsEnabled'] ?? true,
    };
  }

  // ── Save preferences to Firestore ─────────────────────────────────────────
  Future<void> saveSettings({
    required bool biometricEnabled,
    required bool darkMode,
    required String network,
    required bool notificationsEnabled,
  }) async {
    await _userDoc.set({
      'biometricEnabled': biometricEnabled,
      'darkMode': darkMode,
      'network': network,
      'notificationsEnabled': notificationsEnabled,
      'settingsUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ── Change door PIN stored in Firestore ───────────────────────────────────
  Future<void> changePin(String newPin) async {
    await _userDoc.set({
      'pin': newPin,
      'pinUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ── Change Firebase Auth password (requires reauthentication) ─────────────
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = FirebaseAuth.instance.currentUser!;
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }
}
