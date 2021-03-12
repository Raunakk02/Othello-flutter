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

  set isSigningIn(bool isSigninIn) {
    _isSigningIn = isSigninIn;
    notifyListeners();
  }

  Future login() async {
    _isSigningIn = true;

    final user = await googleSignIn.signIn();

    if (user == null) {
      isSigningIn = false;
      return;
    } else {
      final googleAuth = await user.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      isSigningIn = false;
    }
  }

  Future verifyPhone({
    required String phone,
    required void Function(String, int?) codeSentCallback,
    required void Function(String) codeAutoRetrievalTimeoutCallback,
  }) async {
    _isSigningIn = true;

    await auth.verifyPhoneNumber(
      phoneNumber: '+$phone',
      verificationCompleted: (creds) async {
        print('Veriiii completed : $phone');
        var userCreds = await auth.signInWithCredential(creds);
        if (userCreds.user != null) {
          print(userCreds.user!.phoneNumber);
        }
        isSigningIn = false;
      },
      verificationFailed: (e) {
        print('Failed veriii : $phone');
        print(e.message);
      },
      codeSent: codeSentCallback,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeoutCallback,
      timeout: Duration(minutes: 2),
    );
  }

  void logout() async {
    var currentUser = googleSignIn.currentUser;
    if (currentUser != null) {
      await googleSignIn.disconnect();
    }

    FirebaseAuth.instance.signOut();
  }
}
