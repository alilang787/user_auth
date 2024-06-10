import 'package:user_auth/main.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

var logger = Logger();
printLog({String? v}) {
  Logger().i(v ?? 'called');
}

class Utils {
  Utils._(); // Private constructor

  // ========================== Dark Theme ========================

  // ========================== Show Dialog ========================

  static showDialog({
    required BuildContext context,
    required String title,
    required Widget content,
    bool? goHome,
  }) {
    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          title: Text(title),
          content: content,
          actions: [
            TextButton(
              onPressed: () {
                if (goHome != null) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) {
                      return MainApp();
                    },
                  ));
                } else
                  return Navigator.pop(context);
              },
              child: Text('OK'),
            )
          ],
        );
      },
    );
  }

  // ======================== Check Connectivity ============+==========

  static Future<bool> checkConnectivity(BuildContext context) async {
    final List<ConnectivityResult> connectivityResult =
        await _availableConnections();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      Utils.showDialog(
        context: context,
        title: 'No Internet Connection!',
        content: Text('Make sure you have a working internet connection.'),
      );
      return true;
    } else {
      return false;
    }
  }

  static Future<List<ConnectivityResult>> _availableConnections() async {
    final List<ConnectivityResult> connectivityResult =
        await Connectivity().checkConnectivity();
    return connectivityResult;
  }
}
