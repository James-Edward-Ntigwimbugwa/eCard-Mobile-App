import 'package:flutter/material.dart';
import 'package:ecard_app/modals/card_modal.dart';

class CardDisplayWidget extends StatelessWidget {
  final CustomCard card;

  const CardDisplayWidget({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    // Parse colors from string values or use defaults
    final Color backgroundColor =
        _parseColor(card.backgroundColor, Colors.white);
    final Color fontColor = _parseColor(card.fontColor, Colors.black);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Profile photo
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: card.profilePhoto != null
                        ? NetworkImage(card.profilePhoto!)
                        : null,
                    backgroundColor: Colors.grey.shade200,
                    child: card.profilePhoto == null
                        ? const Icon(Icons.person, size: 30)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Company name
                        Text(
                          card.company ?? 'Company Name',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: fontColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Department
                        if (card.department != null)
                          Text(
                            card.department!,
                            style: TextStyle(color: fontColor),
                          ),
                        // Organization
                        if (card.organization != null)
                          Text(
                            card.organization!,
                            style: TextStyle(
                                color: fontColor.withOpacity(0.7),
                                fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              // Contact info
              if (card.email != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.email, size: 16, color: fontColor),
                      const SizedBox(width: 8),
                      Text(card.email!, style: TextStyle(color: fontColor)),
                    ],
                  ),
                ),
              if (card.phoneNumber != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.phone, size: 16, color: fontColor),
                      const SizedBox(width: 8),
                      Text(card.phoneNumber!,
                          style: TextStyle(color: fontColor)),
                    ],
                  ),
                ),
              if (card.address != null)
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: fontColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        card.address!,
                        style: TextStyle(color: fontColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to parse color from string
  Color _parseColor(String? colorString, Color defaultColor) {
    if (colorString == null || colorString.isEmpty) {
      return defaultColor;
    }

    try {
      if (colorString.startsWith('#')) {
        return Color(int.parse('0xFF${colorString.substring(1)}'));
      }
      return defaultColor;
    } catch (e) {
      return defaultColor;
    }
  }
}
