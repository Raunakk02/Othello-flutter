import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:othello/screens/phone_input_screen.dart';

class PhoneSignUpButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.of(context).pushNamed(PhoneInputScreen.routeName);
        },
        icon: FaIcon(
          FontAwesomeIcons.phoneAlt,
          color: Colors.green,
        ),
        label: Text(
          'Sign In With Phone',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        style: OutlinedButton.styleFrom(
          shape: StadiumBorder(),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          primary: Colors.white,
        ),
      ),
    );
  }
}
