import 'package:flutter/material.dart';
import 'package:ecard_app/modals/card_modal.dart';
import 'package:ecard_app/modals/user_modal.dart';
import '../screens/card_details_screen.dart';
import '../preferences/user_preference.dart';

class CardDisplayWidget extends StatefulWidget {
  final CustomCard card;
  final Function(CustomCard)? onCardTap;
  final Function(CustomCard)? onShare;

  const CardDisplayWidget({
    super.key,
    required this.card,
    this.onCardTap,
    this.onShare,
  });

  @override
  State<CardDisplayWidget> createState() => _CardDisplayWidgetState();
}

class _CardDisplayWidgetState extends State<CardDisplayWidget> {
  User? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userPrefs = UserPreferences();
    final userData = await userPrefs.getUser();

    if (mounted) {
      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    }
  }

  void _navigateToCardSaves() {
    try {
      if (widget.card.id != null && widget.card.id!.isNotEmpty) {
        final cardId = int.parse(widget.card.id!);
        Navigator.pushNamed(
          context,
          '/people_card_saves',
          arguments: cardId,
        );
      } else {
        // Show error message if card ID is null or empty
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Card ID not available'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle parsing error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: Invalid card ID format - ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint('Error parsing card ID: ${widget.card.id} - $e');
    }
  }

  /// Helper method to get font family from font style
  String _getFontFamily(String? fontStyle) {
    switch (fontStyle?.toLowerCase()) {
      case 'serif':
        return 'serif';
      case 'mono':
        return 'monospace';
      case 'sans-serif':
      default:
        return 'sans-serif';
    }
  }

  /// Get layout position enum from string
  LayoutPosition _getLayoutPosition(String? position) {
    switch (position?.toLowerCase()) {
      case 'left':
        return LayoutPosition.left;
      case 'right':
        return LayoutPosition.right;
      case 'top':
        return LayoutPosition.top;
      case 'bottom':
        return LayoutPosition.bottom;
      default:
        return LayoutPosition.left;
    }
  }

  /// Build label text widget for card elements
  Widget _buildLabel(String labelText, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        labelText,
        style: TextStyle(
          fontSize: 12,
          color: textColor.withOpacity(0.7),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Build a single card element widget with label on top, icon and value text
  Widget _buildCardElement(
      CardElement element, Color textColor, String fontFamily) {
    IconData iconData;
    String label;
    String value;

    switch (element) {
      case CardElement.organizationName:
        iconData = Icons.business;
        label = 'Organization';
        value = widget.card.organization ?? 'Organization';
        break;
      case CardElement.title:
        iconData = Icons.person;
        label = 'Title';
        value = widget.card.title ?? 'Title';
        break;
      case CardElement.description:
        iconData = Icons.description;
        label = 'Description';
        value = widget.card.cardDescription ?? 'Description';
        break;
      case CardElement.email:
        iconData = Icons.email;
        label = 'Email';
        value = widget.card.email ?? 'Email';
        break;
      case CardElement.phone:
        iconData = Icons.phone;
        label = 'Phone';
        value = widget.card.phoneNumber ?? 'Phone';
        break;
      case CardElement.website:
        iconData = Icons.language;
        label = 'Website';
        value = widget.card.websiteUrl ?? 'Website';
        break;
      case CardElement.linkedIn:
        iconData = Icons.work;
        label = 'LinkedIn';
        value = widget.card.linkedIn ?? 'LinkedIn';
        break;
      case CardElement.department:
        iconData = Icons.corporate_fare;
        label = 'Department';
        value = widget.card.department ?? 'Department';
        break;
    }

    // Only show element if it has a non-empty value
    if (value.isEmpty || value == label) {
      return const SizedBox.shrink();
    }

    TextStyle valueStyle = TextStyle(
      fontSize: 14,
      color: textColor,
      fontFamily: fontFamily,
      fontWeight: FontWeight.w500,
    );

    return Padding(
      key: ValueKey(element),
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label, textColor),
          Row(
            children: [
              Icon(iconData, color: textColor, size: 16),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  value,
                  style: valueStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// Build the card content based on backend styling
  Widget _buildCardContent(Color textColor, String fontFamily) {
    // Get positions from backend data
    final logoPosition = _getLayoutPosition(widget.card.logoPosition);
    final textPosition = _getLayoutPosition(widget.card.textPosition);

    // Build logo widget
    Widget logoWidget = CircleAvatar(
      radius: 30,
      backgroundColor: textColor.withOpacity(0.15),
      backgroundImage: widget.card.profilePhoto != null &&
              widget.card.profilePhoto!.isNotEmpty
          ? NetworkImage(widget.card.profilePhoto!)
          : null,
      child:
          widget.card.profilePhoto == null || widget.card.profilePhoto!.isEmpty
              ? Icon(
                  Icons.business,
                  color: textColor.withOpacity(0.7),
                  size: 24,
                )
              : null,
    );

    // Build text elements - show only non-empty fields
    List<Widget> textElements = [];

    // Define the order of elements to display
    final orderedElements = [
      CardElement.organizationName,
      CardElement.title,
      CardElement.description,
      CardElement.email,
      CardElement.phone,
      CardElement.website,
      CardElement.linkedIn,
      CardElement.department,
    ];

    for (var element in orderedElements) {
      final elementWidget = _buildCardElement(element, textColor, fontFamily);
      if (elementWidget is! SizedBox) {
        textElements.add(elementWidget);
      }
    }

    Widget elementsColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: textElements,
    );

    // Build card content based on positions
    Widget cardContent;
    const double spacing = 16;

    if (logoPosition == LayoutPosition.left &&
        textPosition == LayoutPosition.right) {
      cardContent = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          logoWidget,
          const SizedBox(width: spacing),
          Expanded(child: elementsColumn),
        ],
      );
    } else if (logoPosition == LayoutPosition.right &&
        textPosition == LayoutPosition.left) {
      cardContent = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: elementsColumn),
          const SizedBox(width: spacing),
          logoWidget,
        ],
      );
    } else if (logoPosition == LayoutPosition.top &&
        textPosition == LayoutPosition.bottom) {
      cardContent = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          logoWidget,
          const SizedBox(height: spacing),
          elementsColumn,
        ],
      );
    } else if (logoPosition == LayoutPosition.bottom &&
        textPosition == LayoutPosition.top) {
      cardContent = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          elementsColumn,
          const SizedBox(height: spacing),
          logoWidget,
        ],
      );
    } else {
      // Default to left-right layout
      cardContent = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          logoWidget,
          const SizedBox(width: spacing),
          Expanded(child: elementsColumn),
        ],
      );
    }

    return cardContent;
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor =
        _parseColor(widget.card.backgroundColor, const Color(0xFF1E88E5)) ??
            const Color(0xFF1E88E5);
    Color? textColor = _parseColor(widget.card.fontColor, null);
    final bool isDark = _isColorDark(backgroundColor);
    textColor ??= isDark ? Colors.white : Colors.black87;

    // Get font family from card data
    String fontFamily = _getFontFamily(widget.card.fontStyle);

    return InkWell(
      onTap: () {
        if (widget.onCardTap != null) {
          widget.onCardTap!(widget.card);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CardDetailsPage(
                card: widget.card,
                currentUserId: _userData?.id ?? '',
                isFromShareLink: false,
              ),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: backgroundColor,
        elevation: 8.0,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Header with action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.card.title ?? 'Business Card',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            fontFamily: fontFamily,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildActionButton(
                              icon: widget.card.active
                                  ? Icons.bookmark_add
                                  : Icons.favorite_border,
                              onPressed: _navigateToCardSaves,
                              color: textColor.withOpacity(0.1),
                              iconColor: textColor,
                            ),
                            const SizedBox(width: 4),
                            _buildActionButton(
                              icon: Icons.share,
                              onPressed: () =>
                                  widget.onShare?.call(widget.card),
                              color: textColor.withOpacity(0.1),
                              iconColor: textColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Main card content with dynamic layout
                    _buildCardContent(textColor, fontFamily),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Function()? onPressed,
    required Color color,
    required Color iconColor,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: 18),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      ),
    );
  }

  Color? _parseColor(String? colorStr, Color? defaultColor) {
    if (colorStr == null || colorStr.isEmpty) return defaultColor;

    try {
      if (colorStr.startsWith('#')) {
        String hex = colorStr.substring(1);
        if (hex.length == 8) {
          return Color(int.parse(hex, radix: 16));
        } else if (hex.length == 6) {
          return Color(int.parse('FF$hex', radix: 16));
        }
      }
    } catch (e) {
      debugPrint('Error parsing color: $e');
    }

    return defaultColor;
  }

  bool _isColorDark(Color color) {
    final double brightness =
        (color.red * 299 + color.green * 587 + color.blue * 114) / 1000;
    return brightness < 128;
  }
}

enum LayoutPosition {
  left,
  right,
  top,
  bottom,
}

enum CardElement {
  organizationName,
  title,
  description,
  email,
  phone,
  website,
  linkedIn,
  department,
}
