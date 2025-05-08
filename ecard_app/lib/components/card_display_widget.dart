import 'package:flutter/material.dart';
import 'package:ecard_app/modals/card_modal.dart';

class CardDisplayWidget extends StatelessWidget {
  final CustomCard card;

  const CardDisplayWidget({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    // Parse colors from string values or use defaults
    final Color backgroundColor = Colors.white;
    final Color fontColor = Colors.black87;

    // Get indicator color based on card type or use a default
    Color indicatorColor = _getIndicatorColor(card);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border(
          top: BorderSide(color: indicatorColor, width: 3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile photo
            CircleAvatar(
              radius: 25,
              backgroundImage: card.profilePhoto != null
                  ? NetworkImage(card.profilePhoto!)
                  : null,
              backgroundColor: Colors.grey.shade200,
              child: card.profilePhoto == null
                  ? const Icon(Icons.person, size: 25)
                  : null,
            ),
            const SizedBox(width: 12),

            // Card content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job title
                  Text(
                    card.company ?? 'Company name',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: fontColor,
                    ),
                  ),

                  // Company name
                  Text(
                    card.company ?? 'Company Name',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),

                  // Job description
                  if (card.cardDescription != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        card.cardDescription!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  // Published date
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Published: ${card.publishCard ?? 'Private'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Action buttons
            Column(
              children: [
                IconButton(
                  icon: Icon(
                    card.active
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    color: card.active
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                  onPressed: () {
                    // Toggle favorite
                  },
                  constraints: BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  padding: EdgeInsets.zero,
                ),
                if (card.company == 'Design Studio Co.' ||
                    card.company == 'Global Marketing Solutions')
                  Container(
                    height: 24,
                    width: 24,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        'C',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to determine indicator color based on card info
  Color _getIndicatorColor(CustomCard card) {
    // Example mapping of companies to colors
    // In your implementation, you might want to use a field from the card
    // or derive this from some other property
    if (card.company == 'Tech Solutions Inc.') {
      return Colors.blue;
    } else if (card.company == 'Design Studio Co.') {
      return Colors.purple;
    } else if (card.company == 'Global Marketing Solutions') {
      return Colors.green;
    }

    // Default color - you should replace with your app's primary color
    return Colors.blue;
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
