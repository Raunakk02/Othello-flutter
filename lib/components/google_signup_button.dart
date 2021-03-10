import 'package:flutter/material.dart';

class GoogleSignupButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(Icons.login),
        label: Text(
          'Sign In With Google',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        style: OutlinedButton.styleFrom(
          shape: StadiumBorder(),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          primary: Colors.red,
        ),
      ),
    );
  }
}
