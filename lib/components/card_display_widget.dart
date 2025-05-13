import 'package:flutter/material.dart';
import 'package:ecard_app/modals/card_modal.dart';

class CardDisplayWidget extends StatelessWidget {
  final CustomCard card;
  final Function()? onShare;
  final Function()? onFavorite;

  const CardDisplayWidget({
    super.key,
    required this.card,
    this.onShare,
    this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    // Generate a background color based on the card company or use a default
    final Color backgroundColor = _getCardBackgroundColor(card);

    // Determine text color based on background brightness
    final bool isDark = _isColorDark(backgroundColor);
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color iconColor = isDark ? Colors.white70 : Colors.black54;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row with profile info and action buttons
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile photo with company logo overlay
                Stack(
                  children: [
                    // User profile photo
                    CircleAvatar(
                      radius: 24,
                      backgroundColor:
                          isDark ? Colors.white24 : Colors.grey.shade200,
                      backgroundImage: card.profilePhoto != null
                          ? NetworkImage(card.profilePhoto!)
                          : null,
                      child: card.profilePhoto == null
                          ? Icon(Icons.person,
                              size: 24,
                              color: isDark ? Colors.white : Colors.grey)
                          : null,
                    ),

                    // Company logo overlay (positioned at bottom right of avatar)
                    if (card.cardLogo != null)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          height: 16,
                          width: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: backgroundColor, width: 1.5),
                          ),
                          child: ClipOval(
                            child: Image.network(
                              card.cardLogo!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 12),

                // Name and job title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.organization ?? 'Name',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        card.department ?? 'Job Title',
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        card.company ?? 'Company',
                        style: TextStyle(
                          fontSize: 12,
                          color: textColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                // Action buttons
                Row(
                  children: [
                    // Favorite/Star button
                    IconButton(
                      icon: Icon(
                        card.active ? Icons.star : Icons.star_border,
                        color: iconColor,
                        size: 20,
                      ),
                      onPressed: onFavorite,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),

                    // Share button
                    IconButton(
                      icon: Icon(
                        Icons.share,
                        color: iconColor,
                        size: 20,
                      ),
                      onPressed: onShare,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to determine background color based on card info
  Color _getCardBackgroundColor(CustomCard card) {
    // Map specific companies to colors like in the image
    // First card in image is blue, second is orange
    if (card.company == 'Wealth Partners Inc.') {
      return const Color(0xFF005BBB); // Blue color for first card
    } else if (card.company == 'Sport Central Studio') {
      return const Color(0xFFFF8C00); // Orange color for second card
    }

    // Generate a color based on the company name if no specific mapping
    if (card.company != null) {
      final int hash = card.company!.hashCode;
      final List<Color> colorOptions = [
        const Color(0xFF1E88E5), // Blue
        const Color(0xFFFF8C00), // Orange
        const Color(0xFF43A047), // Green
        const Color(0xFF5E35B1), // Purple
        const Color(0xFFE53935), // Red
      ];
      return colorOptions[hash.abs() % colorOptions.length];
    }

    // Default color
    return const Color(0xFF1E88E5); // Blue
  }

  // Helper method to determine if a color is dark
  bool _isColorDark(Color color) {
    // Calculate perceived brightness using formula:
    // (299 * R + 587 * G + 114 * B) / 1000
    final double brightness =
        (color.red * 299 + color.green * 587 + color.blue * 114) / 1000;
    return brightness < 128; // If less than 128, consider it dark
  }
}
