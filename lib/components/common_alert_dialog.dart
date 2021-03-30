import 'dart:math';

import 'package:flutter/material.dart';

class CommonAlertDialog extends AlertDialog {
  final String titleString;
  final Widget? content;
  final Icon? icon;
  final Function? onPressed;
  final bool error;

  CommonAlertDialog(this.titleString,
      {this.icon, this.onPressed, this.content, this.error = false});

  @override
  Widget build(BuildContext context) {
    double screenWidth = min(MediaQuery.of(context).size.width, 600);
    return AlertDialog(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(screenWidth * 0.03),
        ),
      ),
      content: content,
      title: Row(
        children: <Widget>[
          Expanded(
            flex: 10,
            child: Text(
              titleString,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.only(left: 15),
              child: FittedBox(
                child: icon ??
                    (error
                        ? Icon(Icons.block, color: Colors.red)
                        : Icon(Icons.check_circle_outline,
                            color: Colors.lightGreen)),
              ),
            ),
          )
        ],
      ),
      actions: <Widget>[
        Center(
          child: TextButton(
            child: Text(
              "OK",
              style: TextStyle(
                fontSize: screenWidth * 0.04,
              ),
            ),
            onPressed: onPressed as void Function()? ??
                () {
                  Navigator.of(context).pop();
                },
          ),
        ),
      ],
    );
  }
}
