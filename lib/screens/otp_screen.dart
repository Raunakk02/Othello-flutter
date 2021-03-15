import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pin_put/pin_put.dart';

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
        // onSubmit: (pin) async {
        //   try {
        //     var userCreds = await FirebaseAuth.instance.signInWithCredential(
        //       PhoneAuthProvider.credential(
        //         verificationId: _verificationCode,
        //         smsCode: pin,
        //       ),
        //     );
        //     if (userCreds.user != null) {
        //       print(userCreds.user!.phoneNumber);
        //     }
        //     Navigator.of(context).pushNamed(HomePage.routeName);
        //   } catch (e) {
        //     FocusScope.of(context).unfocus();
        //     _showSnackBar('Invalid OTP');
        //   }
        // },
      ),
    );
  }

  Future verifyPhone({
    required String phone,
    required void Function(String, int?) codeSentCallback,
    required void Function(String) codeAutoRetrievalTimeoutCallback,
  }) async {
    // _isSigningIn = true;
    var auth = FirebaseAuth.instance;

    await auth.verifyPhoneNumber(
      phoneNumber: '+$phone',
      verificationCompleted: (creds) async {
        print('Auto Veriiii completed : $phone');
        var userCreds = await auth.signInWithCredential(creds);
        if (userCreds.user != null) {
          print(userCreds.user!.phoneNumber);
        }
        // isSigningIn = false;
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('DCD');
    if (_isInit) {
      _phone = ModalRoute.of(context)?.settings.arguments as String;
      // final provider =
      //     Provider.of<GoogleSignInProvider>(context, listen: false);
      // provider.isSigningIn = true;
      verifyPhone(
        phone: _phone,
        codeSentCallback: codeSentFunc,
        codeAutoRetrievalTimeoutCallback: codeAutoRetrievalTimeoutFunc,
      );
      // provider.isSigningIn = false;
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          animatingBorders(),
          SizedBox(
            height: 10,
          ),
          OutlinedButton(
            onPressed: () async {
              try {
                var auth = FirebaseAuth.instance;
                var userCreds = await auth.signInWithCredential(
                  PhoneAuthProvider.credential(
                    verificationId: _verificationCode,
                    smsCode: _pinPutController.text.trim(),
                  ),
                );
                if (auth.currentUser != null) {
                  print('Phone auth success: ${userCreds.user!.phoneNumber} \n'
                      'Loading Home Page');
                  FirebaseAuth.instance.currentUser!.reload();

                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/',
                    (route) => false,
                  );
                }
              } catch (e) {
                FocusScope.of(context).unfocus();
                _showSnackBar(e.toString());
              }
            },
            child: Text('Verify OTP'),
          ),
        ],
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
      duration: const Duration(seconds: 60),
      content: Container(
        height: 80.0,
        child: Center(
          child: Text(
            message,
            style: const TextStyle(fontSize: 12.0),
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
