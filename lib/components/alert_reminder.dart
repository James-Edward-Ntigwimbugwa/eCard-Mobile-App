import 'dart:async';
import 'package:flutter/material.dart';
import 'custom_widgets.dart';

class Alerts {
  /// Shows an error alert that is dismissible with an OK button
  static Future<dynamic> showError({
    required BuildContext context,
    required String message,
    required Widget icon,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        // Automatically close the dialog after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });

        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                const SizedBox(height: 20),
                NormalHeaderWidget(
                  text: message,
                  color: Theme.of(context).indicatorColor,
                  size: '24.0',
                ),
              ],
            ),
            backgroundColor: Theme.of(context).secondaryHeaderColor,
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(color: Theme.of(context).indicatorColor),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Shows a success alert that is not dismissible and closes after 3 seconds
  static Future<dynamic> showSuccess({
    required BuildContext context,
    required String message,
    required Widget icon,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        // Automatically close the dialog after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });

        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                const SizedBox(height: 20),
                NormalHeaderWidget(
                  text: message,
                  color: Theme.of(context).primaryColor,
                  size: '24.0',
                ),
              ],
            ),
            backgroundColor: Theme.of(context).secondaryHeaderColor,
          ),
        );
      },
    );
  }

  /// Shows a warning alert that is dismissible with an OK button
  static Future<dynamic> showWarning({
    required BuildContext context,
    required String message,
    required Widget icon,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        // Automatically close the dialog after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });

        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                const SizedBox(height: 20),
                NormalHeaderWidget(
                  text: message,
                  color: Colors.orange,
                  size: '24.0',
                ),
              ],
            ),
            backgroundColor: Theme.of(context).secondaryHeaderColor,
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(color: Theme.of(context).indicatorColor),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Shows a loader alert that is not dismissible
  static Future<dynamic> showLoader({
    required BuildContext context,
    required String message,
    required Widget icon,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(height: 20),
              NormalHeaderWidget(
                text: message,
                color: Theme.of(context).indicatorColor,
                size: '24.0',
              ),
            ],
          ),
          backgroundColor: Theme.of(context).secondaryHeaderColor,
        ),
      ),
    );
  }
}
