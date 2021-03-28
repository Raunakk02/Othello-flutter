import 'dart:developer';

import 'package:flutter/material.dart';
import 'common_alert_dialog.dart';

///Special Accessory function for showing loading before a page.
///
///In [T] section enter type of data future function returns.
class LoadingScreen<T> extends StatelessWidget {
  ///Special Accessory function for showing loading before a page.
  ///
  ///In [T] section enter type of data future function returns.
  LoadingScreen({
    required this.future,
    required this.func,
    this.errFunc,
  }) : assert(future != null);

  ///Future that will be used to get value or perform async operation needed
  ///before loading next page.
  final Future<T>? future;
  final Widget Function(Object? error)? errFunc;

  ///This function will execute after future is complete.
  ///Also this function should return a Widget.
  final Widget Function(T? res) func;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasData)
          return func(snapshot.data);
        else if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError) return func(snapshot.data);
        if (snapshot.hasError) {
          log('err: ${snapshot.error}', name: 'LoadingPage');
          String errMessage = "Something went wrong";
          if (snapshot.error is String) errMessage = snapshot.error as String;
          return errFunc != null
              ? errFunc!(snapshot.error)
              : Scaffold(
                  body: Center(
                    child: CommonAlertDialog(
                      errMessage,
                      error: true,
                    ),
                  ),
                );
        }
        return Scaffold(
          body: Center(
            child: SizedBox(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }
}
