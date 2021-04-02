import 'package:flutter/material.dart';
import 'package:othello/components/common_alert_dialog.dart';

Future<void> shareDynamicLink(BuildContext context, String roomId) async {
  await showDialog(
    context: context,
    builder: (context) => CommonAlertDialog(
      "Cannot share room from web",
      error: true,
    ),
  );
}
