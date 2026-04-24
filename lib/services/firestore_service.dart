import 'package:cloud_firestore/cloud_firestore.dart';

/// Utility service for one-off Firestore operations not covered by
/// the feature-specific services (DoorService, GuestService, etc.)
class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // ── Real-time door status stream ──────────────────────────────────────────
  // Kept for any widget that wants to listen to door_status/main_door directly
  Stream<DocumentSnapshot> getDoorStatus() {
    return _db.collection('door_status').doc('main_door').snapshots();
  }

  // ── Seed smart_contract/config if it doesn't exist ────────────────────────
  // Call once after first login or from a setup screen.
  // Values here are placeholders — replace with real contract details.
  Future<void> seedSmartContractConfig() async {
    final ref = _db.collection('smart_contract').doc('config');
    final doc = await ref.get();
    if (!doc.exists) {
      await ref.set({
        'contractAddress': '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb',
        'network': 'Ethereum Testnet',
        'chainId': 5,
        'blockHeight': '12,345,678',
        'contractVersion': 'v1.2.0',
        'deployedOn': Timestamp.fromDate(DateTime(2026, 1, 15)),
      });
    }
  }

  // ── Seed FAQs collection if empty ─────────────────────────────────────────
  // HelpScreen reads from this collection; static fallback is used if empty.
  Future<void> seedFaqs() async {
    final snap = await _db.collection('faqs').limit(1).get();
    if (snap.docs.isNotEmpty) return;

    final faqs = [
      {
        'order': 1,
        'question': 'How do I unlock the door using fingerprint?',
        'answer':
            'Go to Authentication Methods on the home screen and tap Fingerprint. Make sure your fingerprint is registered in Fingerprint Settings.',
      },
      {
        'order': 2,
        'question': 'What happens if my fingerprint is not recognized?',
        'answer':
            'Use the PIN fallback option. Go to Settings and ensure PIN fallback is enabled. You can also use QR code or PIN to unlock.',
      },
      {
        'order': 3,
        'question': 'How do I grant temporary access to guests?',
        'answer':
            'Navigate to Guest Access from the profile menu. Tap "Add New Guest", select the method and duration, then share the credentials.',
      },
      {
        'order': 4,
        'question': 'How secure is the blockchain integration?',
        'answer':
            'All access attempts are recorded on the blockchain creating an immutable audit trail. Smart contracts ensure only authorized users can unlock.',
      },
      {
        'order': 5,
        'question': 'Can I remove guest access before it expires?',
        'answer':
            'Yes. Go to Guest Access and tap the delete icon next to the guest. Access is immediately removed.',
      },
    ];

    final batch = _db.batch();
    for (final faq in faqs) {
      batch.set(_db.collection('faqs').doc(), faq);
    }
    await batch.commit();
  }
}
