import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'card_modal.dart';

class CardModal extends StatelessWidget {
  final CustomCard card;
  const CardModal({Key? key, required this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    debugPrint("============ Found Id ======== ${card.id} \n "
        "==============");
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(card.title ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('ID: ${card.id}'),
          if (card.company != null) Text('Company: ${card.company}'),
          if (card.organization != null) Text('Organization: ${card.organization}'),
          if (card.phoneNumber != null) Text('Phone: ${card.phoneNumber}'),
          if (card.email != null) Text('Email: ${card.email}'),
          if (card.websiteUrl != null)
            GestureDetector(
              onTap: () async {
                var url = card.websiteUrl!;
                if (!url.startsWith('http')) url = 'https://$url';
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url));
                }
              },
              child: Text('Visit: ${card.websiteUrl}',
                  style: const TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.blue)),
            ),
        ],
      ),
    );
  }
}
