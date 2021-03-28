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
      backgroundColor: Colors.black,
      body: Form(
        key: _formKey,
        child: Center(
          child: Container(
            margin: EdgeInsets.all(30),
            child: TextFormField(
              key: Key('phoneTextField'),
              style: GoogleFonts.montserrat(fontSize: Globals.primaryFontSize),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'Enter phone number',
                prefixIcon: Icon(
                  FontAwesomeIcons.phoneAlt,
                  color: Colors.green,
                ),
                border: OutlineInputBorder(
                  borderRadius: Globals.borderRadius,
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.white24,
                filled: true,
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
