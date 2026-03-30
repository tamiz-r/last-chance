// lib/services/firestore_service.dart  (USER APP)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/poll_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;
  String get _email => _auth.currentUser!.email ?? '';

  // ── POLLS ──────────────────────────────────────────────

  /// Stream of today's active polls (realtime)
  Stream<List<PollModel>> get todayPolls {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _db
        .collection('polls')
        .where('isActive', isEqualTo: true)
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThan: endOfDay)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => PollModel.fromFirestore(d.data(), d.id))
            .toList());
  }

  /// Stream of ALL polls (past + today) for history
  Stream<List<PollModel>> get allPolls {
    return _db
        .collection('polls')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => PollModel.fromFirestore(d.data(), d.id))
            .toList());
  }

  // ── USER SELECTIONS ──────────────────────────────────────

  /// Submit user's choice for a poll (realtime write to Firestore)
  Future<void> submitSelection(String pollId, String option) async {
    final docRef = _db
        .collection('selections')
        .doc('${_uid}_$pollId'); // one selection per user per poll

    await docRef.set({
      'userId': _uid,
      'userEmail': _email,
      'pollId': pollId,
      'selectedOption': option,
      'selectedAt': FieldValue.serverTimestamp(),
      'earnedAmount': null,
      'resultProcessed': false,
    });
  }

  /// Stream user's selection for a specific poll (realtime)
  Stream<UserSelectionModel?> selectionForPoll(String pollId) {
    return _db
        .collection('selections')
        .doc('${_uid}_$pollId')
        .snapshots()
        .map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return UserSelectionModel.fromFirestore(snap.data()!, snap.id);
    });
  }

  /// Stream all selections by this user (for history screen)
  Stream<List<UserSelectionModel>> get mySelections {
    return _db
        .collection('selections')
        .where('userId', isEqualTo: _uid)
        .orderBy('selectedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => UserSelectionModel.fromFirestore(d.data(), d.id))
            .toList());
  }

  // ── WALLET ───────────────────────────────────────────────

  /// Stream user's wallet (realtime balance updates)
  Stream<UserWalletModel?> get myWallet {
    return _db
        .collection('wallets')
        .doc(_uid)
        .snapshots()
        .map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return UserWalletModel.fromFirestore(snap.data()!);
    });
  }
}
