import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../modals/card_modal.dart';

class FoundCard extends StatelessWidget {
  final CustomCard card;
  final VoidCallback? onSaveCard;
  final VoidCallback? onSeeMore;
  
  const FoundCard({
    Key? key, 
    required this.card,
    this.onSaveCard,
    this.onSeeMore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final screenWidth = MediaQuery.of(context).size.width;

    debugPrint("============ Found Card Details ========"
        " ${card.id} \n  , ${card.uuid} \n , ${card.organization} \n "
        "==============");

    return Container(
      width: screenWidth,
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.15),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children:[ Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Success Animation/Icon
              Container(
                width: 80,
                height: 80,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: primaryColor,
                  size: 50,
                ),
              ),
        
              // Title/Company Name
              Text(
                card.company ?? card.title ?? 'Organization',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
        
              // Subtitle (Title if company exists, otherwise show ID)
              if (card.company != null && card.title != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    card.title!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ),
        
              const SizedBox(height: 24),
        
              // Contact Information
              Column(
                children: [
                  _buildContactInfoRow(Icons.credit_card, 'ID: ${card.id}'),
                  if (card.organization != null)
                    _buildContactInfoRow(Icons.business, card.organization!),
                  if (card.phoneNumber != null)
                    _buildContactInfoRow(Icons.phone, card.phoneNumber!),
                  if (card.email != null)
                    _buildContactInfoRow(Icons.email, card.email!),
                  if (card.websiteUrl != null) _buildWebsiteRow(card.websiteUrl!),
                ],
              ),
        
              const SizedBox(height: 32),
            ],
          ),
        ),

        // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onSaveCard,
                    icon: const Icon(Icons.bookmark_add),
                    label: const Text('Save Card'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onSeeMore,
                    icon: const Icon(Icons.info_outline),
                    label: const Text('See More'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: BorderSide(color: primaryColor, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      ]),
    );
  }

  Widget _buildContactInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.grey.shade600,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebsiteRow(String websiteUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.language,
              color: Colors.grey.shade600,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                var url = websiteUrl;
                if (!url.startsWith('http')) url = 'https://$url';
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url));
                }
              },
              child: Text(
                'Visit: $websiteUrl',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}