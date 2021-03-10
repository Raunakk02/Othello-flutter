import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:othello/providers/google_sign_in.dart';
import 'package:provider/provider.dart';

class SideDrawer extends StatelessWidget {
  final photoURL = FirebaseAuth.instance.currentUser?.photoURL;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: Container(),
        ),
        body: ListView(
          children: [
            ListTile(
              leading: CircleAvatar(
                radius: 30,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.network(photoURL!)),
              ),
            ),
            ListTile(
              leading: FaIcon(FontAwesomeIcons.signOutAlt),
              title: Text('Logout'),
              onTap: () {
                final provider =
                    Provider.of<GoogleSignInProvider>(context, listen: false);
                provider.logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
