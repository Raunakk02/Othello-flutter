import 'package:flutter/material.dart';
import 'package:othello/components/google_signup_button.dart';
import 'package:othello/components/phone_signup_button.dart';

class SignUpScreen extends StatelessWidget {
  static const routeName = '/sign-up-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Spacer(),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              width: 175,
              child: Text(
                'Yōkoso to Othello',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Spacer(),
          Text(
            'Login to continue',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(
            height: 12,
          ),
          GoogleSignupButton(),
          PhonesignupButton(),
          Spacer(),
        ],
      ),
    );
  }
}
