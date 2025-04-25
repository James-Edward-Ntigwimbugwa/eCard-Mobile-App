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
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                loader,
                const SizedBox(height: 20),
                NormalHeaderWidget(
                  text: message,
                  color: Theme.of(context).hintColor,
                  size: '24.0',
                ),
              ],
            ),
          ),
          // onTap: () => Navigator.pop(context),
        ),
      ),
    );
  }
}
