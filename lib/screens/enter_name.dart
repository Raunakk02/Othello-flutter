import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:othello/utils/globals.dart';

class EnterName extends StatelessWidget {
  static const routeName = "/enter_name";
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: Form(
            key: _formKey,
            child: TextFormField(
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(fontSize: Globals.primaryFontSize),
              decoration: Globals.textFieldDecoration.copyWith(
                hintText: 'Enter Name',
                prefixIcon: Icon(
                  Icons.account_box_rounded,
                  color: Colors.deepOrange,
                  size: Globals.maxScreenWidth * 0.06,
                ),
              ),
              validator: (text) {
                if (text == null || text.isEmpty) return "Please enter name";
              },
              onFieldSubmitted: (text) {
                if (!_formKey.currentState!.validate()) return;
                Navigator.pop(context, text);
              },
            ),
          ),
        ),
      ),
    );
  }
}
