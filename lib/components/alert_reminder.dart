import 'dart:async';
import 'package:flutter/material.dart';
import 'custom_widgets.dart';

class Alerts {
  static Future<dynamic> show(
      BuildContext context, String message, Widget loader) {
    return showDialog(
      context: context,
      builder: (context) => PopScope(
        canPop: false,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,

          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                loader,
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
          // onTap: () => Navigator.pop(context),
        ),
      ),
    );
  }
}
