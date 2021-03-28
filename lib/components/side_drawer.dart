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
  late User currentUser;

  @override
  void initState() {
    super.initState();
    var auth = FirebaseAuth.instance;
    currentUser = auth.currentUser!;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Scaffold(
        backgroundColor: Colors.brown,
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
                  child: currentUser.photoURL != null
                      ? Image.network(currentUser.photoURL!)
                      : FaIcon(
                          FontAwesomeIcons.phoneAlt,
                          color: Colors.green,
                        ),
                ),
              ),
              title: currentUser.phoneNumber == null
                  ? Text(currentUser.displayName!)
                  : Text(currentUser.phoneNumber!),
            ),
            ListTile(
              leading: FaIcon(FontAwesomeIcons.signOutAlt),
              title: Text('Logout'),
              onTap: () async {
                final provider =
                    Provider.of<GoogleSignInProvider>(context, listen: false);
                await provider.logout(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
