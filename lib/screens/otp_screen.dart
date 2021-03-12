import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:othello/providers/google_sign_in.dart';
import 'package:othello/screens/home_page.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:provider/provider.dart';

class OtpScreen extends StatefulWidget {
  static const routeName = 'otp-screen';

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _pinPutController = TextEditingController();
  final _pinPutFocusNode = FocusNode();

  late final _phone;
  late String _verificationCode;

  var _isInit = true;

  Widget animatingBorders() {
    final BoxDecoration pinPutDecoration = BoxDecoration(
      border: Border.all(color: Colors.greenAccent),
      borderRadius: BorderRadius.circular(15.0),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: PinPut(
        fieldsCount: 6,
        eachFieldHeight: 60.0,
        withCursor: true,
        focusNode: _pinPutFocusNode,
        controller: _pinPutController,
        submittedFieldDecoration: pinPutDecoration.copyWith(
          borderRadius: BorderRadius.circular(30.0),
        ),
        selectedFieldDecoration: pinPutDecoration,
        followingFieldDecoration: pinPutDecoration.copyWith(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: Colors.deepOrangeAccent,
          ),
        ),
        preFilledWidget: Text('-'),
        onSubmit: (pin) async {
          try {
            var userCreds = await FirebaseAuth.instance.signInWithCredential(
              PhoneAuthProvider.credential(
                verificationId: _verificationCode,
                smsCode: pin,
              ),
            );
            if (userCreds.user != null) {
              print(userCreds.user!.phoneNumber);
            }
            Navigator.of(context).pushNamed(HomePage.routeName);
          } catch (e) {
            FocusScope.of(context).unfocus();
            _showSnackBar('Invalid OTP');
          }
        },
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('DCD');
    if (_isInit) {
      _phone = ModalRoute.of(context)?.settings.arguments as String;
      final provider =
          Provider.of<GoogleSignInProvider>(context, listen: false);
      provider.verifyPhone(
        phone: _phone,
        codeSentCallback: codeSentFunc,
        codeAutoRetrievalTimeoutCallback: codeAutoRetrievalTimeoutFunc,
      );
      _isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text('Verify Phone'),
      ),
      body: Center(
        child: animatingBorders(),
      ),
    );
  }

  // void verifyPhone() async {
  //   await FirebaseAuth.instance.verifyPhoneNumber(
  //     phoneNumber: '+$_phone',
  //     verificationCompleted: (creds) async {
  //       final provider =
  //           Provider.of<GoogleSignInProvider>(context, listen: false);
  //       provider.isSigningIn = true;
  //       print('Veriiii completed : $_phone');
  //       var userCreds = await FirebaseAuth.instance.signInWithCredential(creds);
  //       if (userCreds.user != null) {
  //         print(userCreds.user!.phoneNumber);
  //       }
  //       provider.isSigningIn = false;
  //     },
  //     verificationFailed: (e) {
  //       print('Failed veriii : $_phone');
  //       print(e.message);
  //     },
  //     codeSent: ,
  //     codeAutoRetrievalTimeout: ,
  //   );
  // }

  void codeSentFunc(verificationID, resendToken) {
    print('Codee senttt : $_phone');

    setState(() {
      _verificationCode = verificationID;
    });
  }

  void codeAutoRetrievalTimeoutFunc(verificationID) {
    setState(() {
      _verificationCode = verificationID;
    });
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(
      duration: const Duration(seconds: 3),
      content: Container(
        height: 80.0,
        child: Center(
          child: Text(
            message,
            style: const TextStyle(fontSize: 25.0),
          ),
        ),
      ),
      backgroundColor: Colors.deepPurpleAccent,
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
