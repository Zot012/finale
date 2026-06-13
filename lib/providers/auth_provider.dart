import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  // Lazily initialize Firebase/GoogleSignIn so tests can construct
  // AuthProvider without requiring Firebase.initializeApp().
  late final FirebaseAuth _auth = FirebaseAuth.instance;
  // google_sign_in v7 uses a singleton API. Initialize once before use.
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleInitialized = false;

  User? get user => _auth.currentUser;
  bool get isSignedIn => user != null;

  Future<void> signInWithGoogle() async {
    try {
      await _ensureGoogleInitialized();
      await _clearGoogleSession(disconnect: false);

      final googleUser = await _authenticateWithRecovery();
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      notifyListeners();
    } catch (e, st) {
      // Log detailed error for platform/Pigeon issues to help diagnosis
      // ignore: avoid_print
      print('AuthProvider.signInWithGoogle ERROR: $e');
      // ignore: avoid_print
      print(st);
      rethrow;
    }
  }

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;

    // Provide the serverClientId (OAuth client ID) for Android.
    // This should match the Web/Server client ID in google-services.json.
    await _googleSignIn.initialize(
      serverClientId:
          '873987138688-mfbdh1odegi0eilitt40qq62ec0782im.apps.googleusercontent.com',
    );
    _googleInitialized = true;
  }

  Future<GoogleSignInAccount> _authenticateWithRecovery() async {
    try {
      return await _googleSignIn.authenticate();
    } on GoogleSignInException catch (e) {
      if (!_isAccountReauthFailure(e)) rethrow;

      await _clearGoogleSession(disconnect: true);
      try {
        return await _googleSignIn.authenticate();
      } on GoogleSignInException catch (retryError) {
        if (_isAccountReauthFailure(retryError)) {
          rethrow;
        }
        rethrow;
      }
    }
  }

  bool _isAccountReauthFailure(GoogleSignInException e) {
    return e.toString().contains('Account reauth failed');
  }

  Future<void> _clearGoogleSession({required bool disconnect}) async {
    try {
      await _auth.signOut();
    } catch (_) {}
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    if (!disconnect) return;
    try {
      await _googleSignIn.disconnect();
    } catch (_) {}
  }

  Future<void> signOut() async {
    await _ensureGoogleInitialized();
    await _clearGoogleSession(disconnect: true);
    notifyListeners();
  }
}
