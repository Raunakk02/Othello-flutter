import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:othello/objects/profile.dart';
import 'package:othello/utils/networks.dart';

class GoogleSignInProvider with ChangeNotifier {
  final googleSignIn = GoogleSignIn();
  final auth = FirebaseAuth.instance;
  late Profile? __profile;
  late bool _isSigningIn;

  Profile? get profile => profile;

  set _profile(Profile profile) {
    this.__profile = profile;
    notifyListeners();
  }

  GoogleSignInProvider() {
    _isSigningIn = false;
  }

  bool get isSigningIn => _isSigningIn;

  set setSigningIn(bool isSigningIn) {
    _isSigningIn = isSigningIn;
    notifyListeners();
  }

  Future<Profile?> setProfile() async {
    final user = auth.currentUser;
    if (this.profile == null || user == null) return Future.value(null);
    final profile = await Networks.getProfile(user.uid);
    if (profile != null) {
      _profile = profile;
      return this.profile;
    }

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

  Future<void> logout(BuildContext context) async {
    var currentUser = googleSignIn.currentUser;
    if (currentUser != null) {
      await googleSignIn.disconnect();
    }
    FirebaseAuth.instance.signOut();
  }
}
