import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PhoneInputScreen extends StatefulWidget {
  static const routeName = '/phone-input-screen';
  @override
  _PhoneInputScreenState createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  var phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text('SignUp With Phone'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.all(30),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Enter phone number with Country code',
                icon: FaIcon(
                  FontAwesomeIcons.phoneAlt,
                  color: Colors.green,
                ),
                labelStyle: TextStyle(
                  color: Colors.white,
                ),
                hintText: 'Eg:- 918888844444',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
              controller: phoneNumberController,
              keyboardType: TextInputType.number,
              maxLength: 12,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text('Submit'),
            style: TextButton.styleFrom(
              primary: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
