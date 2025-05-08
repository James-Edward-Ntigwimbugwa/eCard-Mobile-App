import 'package:ecard_app/utils/raw/top_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TopIconListItems {}

class CardIconListItems {
  static List<TopIconModal> topIcons(BuildContext context) {
    return [
      TopIconModal(
          iconColor: Theme.of(context).primaryColor,
          backgroundColor: Theme.of(context).highlightColor,
          icon: CupertinoIcons.add,
          location: '/edit_profile'),
      TopIconModal(
          iconColor: Theme.of(context).primaryColor,
          backgroundColor: Theme.of(context).cardColor,
          icon: Icons.share,
          location: '/share')
    ];
  }

  static List<TopIconModal> loginIcons(BuildContext context) {
    return [
      TopIconModal(
          iconColor: Theme.of(context).highlightColor,
          backgroundColor: Theme.of(context).primaryColor,
          icon: CupertinoIcons.creditcard_fill,
          location: '/edit_profile'),
      TopIconModal(
          iconColor: Theme.of(context).primaryColor,
          backgroundColor: Theme.of(context).highlightColor,
          icon: CupertinoIcons.mail_solid,
          location: '/share'),
      TopIconModal(
          iconColor: Theme.of(context).primaryColor,
          backgroundColor: Theme.of(context).highlightColor,
          icon: Icons.contacts,
          location: '/share'),
      TopIconModal(
          iconColor: Theme.of(context).primaryColor,
          backgroundColor: Theme.of(context).cardColor,
          icon: Icons.contactless,
          location: '/share'),
    ];
  }
}

class LoginWidgetClickableIcons {
  static List<TopIconModal> icons(BuildContext context) {
    return [
      TopIconModal(
          iconColor: Theme.of(context).highlightColor,
          backgroundColor: Theme.of(context).primaryColor,
          icon: FontAwesomeIcons.google,
          location: '/edit_profile'),
      TopIconModal(
          iconColor: Theme.of(context).highlightColor,
          backgroundColor: Theme.of(context).primaryColor,
          icon: FontAwesomeIcons.facebook,
          location: '/edit_profile'),
      TopIconModal(
          iconColor: Theme.of(context).highlightColor,
          backgroundColor: Theme.of(context).primaryColor,
          icon: FontAwesomeIcons.github,
          location: '/edit_profile'),
    ];
  }
}
