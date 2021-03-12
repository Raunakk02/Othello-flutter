import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:othello/providers/google_sign_in.dart';
import 'package:provider/provider.dart';

class SideDrawer extends StatefulWidget {
  @override
  _SideDrawerState createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  String? photoURL;

  String? userName;

  String? phoneNumber;

  @override
  void initState() {
    super.initState();
    photoURL = FirebaseAuth.instance.currentUser?.photoURL;

    userName = FirebaseAuth.instance.currentUser?.displayName;

    phoneNumber = FirebaseAuth.instance.currentUser?.phoneNumber;
  }

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
                  child: photoURL != null
                      ? Image.network(photoURL!)
                      : FaIcon(
                          FontAwesomeIcons.phoneAlt,
                          color: Colors.green,
                        ),
                ),
              ),
              title:
                  userName!.isNotEmpty ? Text(userName!) : Text(phoneNumber!),
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
