import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Core {
  static void showToast(bool mounted, BuildContext context, String msg) {
    if (mounted) {
      Fluttertoast.showToast(
          msg: msg,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: Theme.of(context).colorScheme.onSurface,
          textColor: Theme.of(context).scaffoldBackgroundColor,
          fontSize: 14.0);
    }
  }
}
