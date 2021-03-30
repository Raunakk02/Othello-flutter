import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:othello/screens/otp_screen.dart';
import 'package:othello/utils/globals.dart';

class PhoneInputScreen extends StatefulWidget {
  static const routeName = '/phone-input-screen';

  @override
  _PhoneInputScreenState createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  var phoneNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 400,
            ),
            margin: EdgeInsets.all(30),
            child: TextFormField(
              key: Key('phoneTextField'),
              style: GoogleFonts.montserrat(
                fontSize: Globals.primaryFontSize,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              decoration: Globals.textFieldDecoration.copyWith(
                hintText: 'Enter phone number',
                prefixIcon: Icon(
                  FontAwesomeIcons.phoneAlt,
                  color: Colors.green,
                ),
              ),
              controller: phoneNumberController,
              keyboardType: TextInputType.number,
              maxLength: 10,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              onFieldSubmitted: (text) {
                if (_formKey.currentState?.validate() != true) return;
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => OtpScreen('+91' + text),
                ));
              },
              validator: (text) {
                if (text == null || text.isEmpty)
                  return "Please Enter Phone Number";
                double? number = double.tryParse(text);
                if (number == null || number < 1e+9)
                  return "Please Enter Valid Number";
              },
            ),
          ),
        ),
      ),
    );
  }
}
