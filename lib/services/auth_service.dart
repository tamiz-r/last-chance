// lib/services/auth_service.dart  (USER APP)

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  Future<UserCredential> register(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    // Create wallet doc for new user
    await _db.collection('wallets').doc(cred.user!.uid).set({
      'userId': cred.user!.uid,
      'email': email.trim(),
      'balance': 0.0,
      'totalEarned': 0.0,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
    return cred;
  }

  Future<void> signOut() async => await _auth.signOut();
}
