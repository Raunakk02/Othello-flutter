import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInProvider with ChangeNotifier {
  final googleSignIn = GoogleSignIn();
  final auth = FirebaseAuth.instance;
  late bool _isSigningIn;

  GoogleSignInProvider() {
    _isSigningIn = false;
  }

  bool get isSigningIn => _isSigningIn;

  set setSigningIn(bool isSigninIn) {
    _isSigningIn = isSigninIn;
    notifyListeners();
  }

  Future login() async {
    _isSigningIn = true;

    final user = await googleSignIn.signIn();

    if (user == null) {
      setSigningIn = false;
      return;
    } else {
      final googleAuth = await user.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      setSigningIn = false;
    }
  }

  void logout() async {
    var currentUser = googleSignIn.currentUser;
    if (currentUser != null) {
      await googleSignIn.disconnect();
    }

    FirebaseAuth.instance.signOut();
  }
}
