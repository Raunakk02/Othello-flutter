import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:othello/utils/globals.dart';
import 'package:pinput/pin_put/pin_put.dart';

class OtpScreen extends StatefulWidget {
  static const routeName = 'otp-screen';

  OtpScreen(this.number);

  final String number;

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _pinPutController = TextEditingController();
  final _pinPutFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  var _isEnabled = true;

  late final _phone;
  late String _verificationCode;

  Widget animatingBorders() {
    final BoxDecoration pinPutDecoration = BoxDecoration(
      color: Colors.white24,
      borderRadius: BorderRadius.circular(Globals.maxScreenWidth * 0.02),
    );
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: PinPut(
          enabled: _isEnabled,
          fieldsCount: 6,
          eachFieldHeight: Globals.maxScreenWidth * 0.12,
          eachFieldWidth: Globals.maxScreenWidth * 0.08,
          textStyle: Globals.primaryTextStyle,
          withCursor: true,
          focusNode: _pinPutFocusNode,
          controller: _pinPutController,
          submittedFieldDecoration: pinPutDecoration,
          selectedFieldDecoration: pinPutDecoration,
          followingFieldDecoration: pinPutDecoration.copyWith(
            color: Colors.white12,
          ),
          preFilledWidget: Text(''),
          validator: (text) {
            if (text == null || text.isEmpty) return "Please enter OTP";
            final otp = double.tryParse(text);
            if (otp == null || otp < 1e+5) return "Please enter valid OTP";
          },
        ),
      ),
    );
  }

  Future verifyPhone({
    required String phone,
    required void Function(String, int?) codeSentCallback,
    required void Function(String) codeAutoRetrievalTimeoutCallback,
  }) async {
    var auth = FirebaseAuth.instance;
    setState(() {
      _isEnabled = false;
    });

    await auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (creds) async {
        setState(() {
          _isEnabled = false;
        });
        print('Auto Veriiii completed : $phone');
        var userCreds = await auth.signInWithCredential(creds);
        if (auth.currentUser != null) {
          print('Phone Auto auth success: ${userCreds.user!.phoneNumber} \n'
              'Loading Home Page');
          await FirebaseAuth.instance.currentUser!.reload();
        }
      },
      verificationFailed: (e) {
        print('Failed veriii : $phone');
        print(e.message);
      },
      codeSent: codeSentCallback,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeoutCallback,
      timeout: Duration(minutes: 1),
    );
  }

  @override
  void initState() {
    _phone = widget.number;
    verifyPhone(
      phone: _phone,
      codeSentCallback: codeSentFunc,
      codeAutoRetrievalTimeoutCallback: codeAutoRetrievalTimeoutFunc,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text('Enter OTP'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          animatingBorders(),
          SizedBox(
            height: 10,
          ),
          _isEnabled
              ? TextButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() != true) return;
                    try {
                      var auth = FirebaseAuth.instance;
                      var userCreds = await auth.signInWithCredential(
                        PhoneAuthProvider.credential(
                          verificationId: _verificationCode,
                          smsCode: _pinPutController.text.trim(),
                        ),
                      );
                      if (auth.currentUser != null) {
                        print(
                            'Phone auth success: ${userCreds.user!.phoneNumber} \n'
                            'Loading Home Page');
                        await FirebaseAuth.instance.currentUser!.reload();
                      }
                    } catch (e) {
                      FocusScope.of(context).unfocus();
                      _showSnackBar(e.toString());
                      setState(() {
                        _isEnabled = true;
                      });
                    }
                  },
                  child: Text('Verify', style: Globals.primaryTextStyle),
                )
              : Container(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.green,
                  ),
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
    _showSnackBar('OTP sent to $_phone');
    setState(() {
      _isEnabled = true;
    });

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
      duration: const Duration(seconds: 5),
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
