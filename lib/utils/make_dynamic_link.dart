import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:othello/components/common_alert_dialog.dart';
import 'package:othello/components/future_dialog.dart';
import 'package:othello/screens/online_rooms.dart';
import 'package:share/share.dart';

import 'globals.dart';

Future<Uri> getSharableDynamicLink(String roomId) async {
  final parameters = DynamicLinkParameters(
      uriPrefix: Globals.URI_PREFIX,
      link: Uri.parse(Globals.BASE_LINK + "${OnlineRooms.routeName}/$roomId"),
      androidParameters: AndroidParameters(
        packageName: 'com.vishnuworld.othello',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: "Invitation to Othello Room",
        description:
            "Let's play othello, I would like you to join my othello room",
        imageUrl: Uri.parse(Globals.ICON_URL),
      ));

  return (await parameters.buildShortLink()).shortUrl;
}

Future<void> shareDynamicLink(BuildContext context, String roomId) async {
  Uri? sharableLink = await showDialog<Uri>(
    context: context,
    builder: (context) => FutureDialog<Uri>(
      future: getSharableDynamicLink(roomId),
      hasData: (link) {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          Navigator.pop(context, link);
        });
        if (link != null) return CommonAlertDialog("Got the Link");
        return CommonAlertDialog("Cannot share room", error: true);
      },
    ),
  );
  if (sharableLink != null) Share.share(sharableLink.toString());
}
