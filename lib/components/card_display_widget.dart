import 'package:flutter/material.dart';
import 'package:ecard_app/modals/card_modal.dart';
import 'package:ecard_app/modals/user_modal.dart';
import '../screens/card_details_screen.dart';
import '../preferences/user_preference.dart';

class CardDisplayWidget extends StatefulWidget {
  final CustomCard card;
  final Function(CustomCard)? onCardTap;
  final Function(CustomCard)? onShare;
  final Function(CustomCard)? onFavorite;

  const CardDisplayWidget({
    super.key,
    required this.card,
    this.onCardTap,
    this.onShare,
    this.onFavorite,
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

  @override
  Widget build(BuildContext context) {
    Color backgroundColor =
        _parseColor(widget.card.backgroundColor, const Color(0xFF1E88E5)) ??
            const Color(0xFF1E88E5);
    Color? textColor = _parseColor(widget.card.fontColor, null);
    final bool isDark = _isColorDark(backgroundColor);
    textColor ??= isDark ? Colors.white : Colors.black87;

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
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Logo + Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: textColor.withOpacity(0.1),
                              backgroundImage: widget.card.profilePhoto != null
                                  ? NetworkImage(widget.card.profilePhoto!)
                                  : null,
                              child: widget.card.profilePhoto == null
                                  ? Icon(Icons.business,
                                      color: textColor.withOpacity(0.7),
                                      size: 16)
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _userData?.companyName ??
                                  widget.card.organization ??
                                  'Organization',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildActionButton(
                              icon: widget.card.active
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              onPressed: () =>
                                  widget.onFavorite?.call(widget.card),
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
                    const SizedBox(height: 20),

                    // Card Title (Main Header)
                    Text(
                      widget.card.title ?? 'Business Card',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Name of Card Creator
                    Text(
                      _getFullName(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Position/Reputation
                    Text(
                      _userData?.jobTitle ?? _userData?.jobTitle ?? 'Position',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: textColor.withOpacity(0.8),
                      ),
                    ),

                    const SizedBox(height: 12),
                    Divider(height: 1, color: textColor.withOpacity(0.2)),
                    const SizedBox(height: 12),

                    // Contact Details
                    Row(
                      children: [
                        Icon(Icons.phone, color: textColor, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          _userData?.phone ??
                              widget.card.phoneNumber ??
                              'Phone Number',
                          style: TextStyle(
                            fontSize: 14,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(Icons.email, color: textColor, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          _userData?.email ??
                              widget.card.email ??
                              'Email Address',
                          style: TextStyle(
                            fontSize: 14,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
      ),
    );
  }

  String _getFullName() {
    if (_userData != null) {
      final firstName = _userData!.firstName;
      final lastName = _userData!.lastName;

      if (firstName!.isNotEmpty || lastName!.isNotEmpty) {
        return '$firstName $lastName'.trim();
      }
    }
    return widget.card.company ?? 'Card Creator';
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

  // Helper method to parse color string (hex or named)
  Color? _parseColor(String? colorStr, Color? defaultColor) {
    if (colorStr == null || colorStr.isEmpty) return defaultColor;

    try {
      // Handle color format from backend: "#ffXXXXXX" where ff is alpha and XXXXXX is RGB
      if (colorStr.startsWith('#')) {
        String hex = colorStr.substring(1);

        // If format is "#ffXXXXXX" (with alpha channel)
        if (hex.length == 8) {
          return Color(int.parse(hex, radix: 16));
        }
        // If format is "#XXXXXX" (no alpha channel)
        else if (hex.length == 6) {
          return Color(int.parse('FF$hex', radix: 16));
        }
      }
    } catch (e) {
      debugPrint('Error parsing color: $e');
    }

    return defaultColor;
  }

  // Helper method to check if a color is dark
  bool _isColorDark(Color color) {
    final double brightness =
        (color.red * 299 + color.green * 587 + color.blue * 114) / 1000;
    return brightness < 128; // If less than 128, consider it dark
  }
}
