import 'dart:ui';

import 'package:ecard_app/services/cad_service.dart';
import 'package:flutter/material.dart';
import 'package:ecard_app/modals/card_modal.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CardDetailsPage extends StatelessWidget {
  final CustomCard card;

  const CardDetailsPage(
      {super.key,
      required this.card,
      required currentUserId,
      required bool isFromShareLink});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor =
        _parseColor(card.backgroundColor, const Color(0xFF1E88E5)) ??
            const Color(0xFF1E88E5);
    Color? textColor = _parseColor(card.fontColor, null);
    final bool isDark = _isColorDark(backgroundColor);
    textColor ??= isDark ? Colors.white : Colors.black87;
    final primaryColor = Theme.of(context).primaryColor;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: screenHeight * 0.4,
              // Take up 40% of screen height
              floating: false,
              pinned: true,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    // Show options menu
                  },
                ),
              ],
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              title: innerBoxIsScrolled
                  ? const Text(
                      'Card Details',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    )
                  : null,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: Colors.white,
                  child: Stack(
                    children: [
                      // Card header
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 50,
                        left: 20,
                        right: 20,
                        child: Text(
                          card.title ?? 'Card Details',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Custom Card
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 90,
                        left: 20,
                        right: 20,
                        bottom: 20,
                        child: _buildBusinessCard(context, screenHeight),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Action Buttons
              SizedBox(
                height: 120, // Adjust height as needed
                child: GridView.count(
                  padding: const EdgeInsets.only(bottom: 10),
                  crossAxisCount: 5,
                  // Increased from 4 to 5 to add Share button
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 8,
                  children: [
                    _buildActionButton(
                      context,
                      icon: Icons.call,
                      label: 'Call',
                      color: primaryColor.withOpacity(0.6),
                      iconColor: Colors.white,
                      onTap: () => card.phoneNumber != null
                          ? _launchPhone(card.phoneNumber!)
                          : null,
                    ),
                    _buildActionButton(
                      context,
                      icon: Icons.email,
                      label: 'Email',
                      color: primaryColor.withOpacity(0.6),
                      iconColor: Colors.white,
                      onTap: () =>
                          card.email != null ? _launchEmail(card.email!) : null,
                    ),
                    _buildActionButton(
                      context,
                      icon: Icons.message,
                      label: 'Message',
                      color: primaryColor.withOpacity(0.6),
                      iconColor: Colors.white,
                      onTap: () => card.phoneNumber != null
                          ? _launchSms(card.phoneNumber!)
                          : null,
                    ),
                    _buildActionButton(
                      context,
                      icon: Icons.save_alt,
                      label: 'Save',
                      color: primaryColor.withOpacity(0.6),
                      iconColor: Colors.white,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Saving contact...')),
                        );
                      },
                    ),
                    // Added Share button
                    _buildActionButton(
                      context,
                      icon: Icons.share,
                      label: 'Share',
                      color: primaryColor.withOpacity(0.6),
                      iconColor: Colors.white,
                      onTap: () => _showShareModal(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Contact Information Section
              _buildSectionHeader('Contact Information'),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (card.phoneNumber != null &&
                          card.phoneNumber!.isNotEmpty)
                        _buildContactItem(
                          icon: Icons.phone,
                          title: 'Phone',
                          value: card.phoneNumber!,
                          onTap: () => _launchPhone(card.phoneNumber!),
                        ),
                      if (card.email != null && card.email!.isNotEmpty)
                        _buildContactItem(
                          icon: Icons.email,
                          title: 'Email',
                          value: card.email!,
                          onTap: () => _launchEmail(card.email!),
                        ),
                      if (card.websiteUrl != null &&
                          card.websiteUrl!.isNotEmpty)
                        _buildContactItem(
                          icon: Icons.language,
                          title: 'Website',
                          value: card.websiteUrl!,
                          onTap: () => _launchUrl(card.websiteUrl!),
                        ),
                      if (card.address != null && card.address!.isNotEmpty)
                        _buildContactItem(
                          icon: Icons.location_on,
                          title: 'Address',
                          value: card.address!,
                          onTap: () => _launchMaps(card.address!),
                          isLast: true,
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Social Media Section
              _buildSectionHeader('Social Media'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSocialButton(
                      label: 'LinkedIn',
                      icon: 'assets/icons/linkedin.png',
                      color: Colors.blue.shade700,
                      onTap: () => card.linkedIn != null
                          ? _launchUrl(card.linkedIn!)
                          : null,
                    ),
                    _buildSocialButton(
                      label: 'Twitter',
                      icon: 'assets/icons/twitter.png',
                      color: Colors.blue.shade400,
                      onTap: () {},
                    ),
                    _buildSocialButton(
                      label: 'Instagram',
                      icon: 'assets/icons/instagram.png',
                      color: Colors.pink,
                      onTap: () {},
                    ),
                    _buildSocialButton(
                      label: 'Facebook',
                      icon: 'assets/icons/facebook.png',
                      color: Colors.blue.shade900,
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Card Analytics
              _buildSectionHeader('Card Analytics', trailing: 'Last 30 days'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAnalyticItem('0', 'Views'),
                    _buildAnalyticItem('0', 'Saves'),
                    _buildAnalyticItem('0', 'Shares'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Ratings
              _buildSectionHeader('Ratings'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildRatingBar(context, 'Positive', 0.75, Colors.green),
                    const SizedBox(height: 8),
                    _buildRatingBar(context, 'Neutral', 0.18, Colors.grey),
                    const SizedBox(height: 8),
                    _buildRatingBar(context, 'Negative', 0.07, Colors.red),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Rate This Card
              _buildSectionHeader('Rate This Card'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildRatingButton(
                      icon: Icons.thumb_up,
                      label: 'Positive',
                      color: Colors.green,
                    ),
                    _buildRatingButton(
                      icon: Icons.remove,
                      label: 'Neutral',
                      color: Colors.grey,
                    ),
                    _buildRatingButton(
                      icon: Icons.thumb_down,
                      label: 'Negative',
                      color: Colors.red,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // New method to show the share modal
  void _showShareModal(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final screenWidth = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Transparent background
      builder: (context) => Stack(
        children: [
          // Blurred background
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color:
                    Colors.black.withOpacity(0.5), // Dark overlay for contrast
              ),
            ),
          ),
          // Styled modal content
          Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 40,
                    offset: const Offset(0, -5),
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    width: screenWidth * 0.9,
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.93,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Share this Card',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.white),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          ),
                          // Description
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'Share your digital business card with others via QR code or through your favorite social platforms.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          // QR Code Section
                          Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: QrImageView(
                                    data: _generateCardQrData(),
                                    version: QrVersions.auto,
                                    size: 200,
                                    backgroundColor: Colors.white,
                                    embeddedImage: card.profilePhoto != null
                                        ? NetworkImage(card.profilePhoto!)
                                            as ImageProvider
                                        : null,
                                    embeddedImageStyle: QrEmbeddedImageStyle(
                                      size: const Size(40, 40),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  'Scan to view ${card.title ?? "this card"}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.download),
                                  label: const Text('Save QR Code'),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('QR Code saved to gallery')),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Divider
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                const Expanded(child: Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Text(
                                    'OR SHARE VIA',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),
                          ),
                          // Social Media Sharing Options
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: GridView.count(
                              crossAxisCount: 4,
                              mainAxisSpacing: 15,
                              crossAxisSpacing: 15,
                              childAspectRatio: 1,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                _buildShareOption(
                                  context,
                                  icon: Icons.message,
                                  color: Colors.green,
                                  label: 'Message',
                                  onTap: () => _shareViaSms(),
                                ),
                                _buildShareOption(
                                  context,
                                  icon: Icons.email,
                                  color: Colors.red.shade700,
                                  label: 'Email',
                                  onTap: () => _shareViaEmail(),
                                ),
                                _buildShareOption(
                                  context,
                                  icon: Icons.facebook,
                                  color: Colors.blue.shade900,
                                  label: 'Facebook',
                                  onTap: () => _shareViaSocialMedia('facebook'),
                                ),
                                _buildShareOption(
                                  context,
                                  icon: Icons.link,
                                  color: Colors.purple,
                                  label: 'Copy Link',
                                  onTap: () => _copyCardLink(context),
                                ),
                                _buildShareOption(
                                  context,
                                  icon: Icons.share,
                                  color: Colors.orange,
                                  label: 'More',
                                  onTap: () => _shareViaSystem(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build share option buttons
  Widget _buildShareOption(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 90,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48, // Reduced from 50
              height: 48, // Reduced from 50
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 10, // Reduced from 11
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _generateCardQrData() {
    // Create a formatted string with all card details
    String qrData = '';

    // Essential identification fields
    if (card.id != null && card.id!.isNotEmpty) {
      qrData += 'ID:${card.id}\n';
    }

    if (card.uuid != null && card.uuid!.isNotEmpty) {
      qrData += 'UUID:${card.uuid}\n';
    }

    // Organization information
    if (card.company != null && card.company!.isNotEmpty) {
      qrData += 'ORG:${card.company}\n';
    }

    if (card.organization != null && card.organization!.isNotEmpty) {
      qrData += 'ORGANIZATION:${card.organization}\n';
    }

    // Personal information
    if (card.title != null && card.title!.isNotEmpty) {
      qrData += 'TITLE:${card.title}\n';
    }

    if (card.department != null && card.department!.isNotEmpty) {
      qrData += 'DEPT:${card.department}\n';
    }

    // Contact information
    if (card.phoneNumber != null && card.phoneNumber!.isNotEmpty) {
      qrData += 'TEL:${card.phoneNumber}\n';
    }

    if (card.email != null && card.email!.isNotEmpty) {
      qrData += 'EMAIL:${card.email}\n';
    }

    if (card.websiteUrl != null && card.websiteUrl!.isNotEmpty) {
      qrData += 'URL:${card.websiteUrl}\n';
    }

    if (card.address != null && card.address!.isNotEmpty) {
      qrData += 'ADR:${card.address}\n';
    }

    if (card.linkedIn != null && card.linkedIn!.isNotEmpty) {
      qrData += 'LINKEDIN:${card.linkedIn}\n';
    }

    // Additional information
    if (card.cardDescription != null && card.cardDescription!.isNotEmpty) {
      qrData += 'DESC:${card.cardDescription}\n';
    }

    if (card.profilePhoto != null && card.profilePhoto!.isNotEmpty) {
      qrData += 'PHOTO:${card.profilePhoto}\n';
    }

    // Styling information
    if (card.backgroundColor != null && card.backgroundColor!.isNotEmpty) {
      qrData += 'BGCOLOR:${card.backgroundColor}\n';
    }

    if (card.fontColor != null && card.fontColor!.isNotEmpty) {
      qrData += 'FONTCOLOR:${card.fontColor}\n';
    }

    // Status information
    qrData += 'ACTIVE:${card.active}\n';
    qrData += 'PUBLISHED:${card.publishCard}\n';

    return qrData.isEmpty ? 'No card data available' : qrData;
  }

  // Share methods
  void _shareViaSms() {
    if (card.phoneNumber != null) {
      final message = 'Check out ${card.title}\'s business card!';
      final Uri uri = Uri.parse('sms:?body=$message');
      launchUrl(uri);
    }
  }

  void _shareViaEmail() {
    if (card.email != null) {
      final subject = 'Business Card: ${card.title ?? "Contact"}';
      final body = 'Please find attached the business card for ${card.title}.';
      final Uri uri = Uri.parse('mailto:?subject=$subject&body=$body');
      launchUrl(uri);
    }
  }

  void _shareViaSocialMedia(String platform) {
    // Implementation depends on what social media integrations you have
    // Could use platform-specific share plugins
  }

  void _copyCardLink(BuildContext context) {
    // Implementation would copy a shareable URL to clipboard
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Card link copied to clipboard')),
    );
  }

  void _shareViaSystem() {
    // Implementation would use platform share dialog
    // This typically requires a share plugin like share_plus
  }

  Widget _buildBusinessCard(BuildContext context, double screenHeight) {
    Color backgroundColor =
        _parseColor(card.backgroundColor, const Color(0xFF1E88E5)) ??
            const Color(0xFF1E88E5);
    Color? textColor = _parseColor(card.fontColor, null);
    final bool isDark = _isColorDark(backgroundColor);
    textColor ??= isDark ? Colors.white : Colors.black87;

    return Container(
      height:
          screenHeight * 0.25, // Significantly increased height for the card
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar/logo with larger size
          CircleAvatar(
            radius: 36, // Significantly increased
            backgroundColor: textColor.withOpacity(0.1),
            backgroundImage: card.profilePhoto != null
                ? NetworkImage(card.profilePhoto!)
                : null,
            child: card.profilePhoto == null
                ? Icon(Icons.business,
                    color: textColor.withOpacity(0.7), size: 36)
                : null,
          ),
          const SizedBox(width: 20),

          // Card information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  card.company ?? 'Organization',
                  style: TextStyle(
                    fontSize: 22, // Increased font size
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  card.title ?? 'Position',
                  style: TextStyle(
                    fontSize: 18, // Increased font size
                    color: textColor.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 16), // Increased spacing
                Row(
                  children: [
                    Icon(Icons.phone, color: textColor, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        card.phoneNumber ?? 'Phone number',
                        style: TextStyle(
                          fontSize: 16, // Increased font size
                          color: textColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.email, color: textColor, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        card.email ?? 'Email address',
                        style: TextStyle(
                          fontSize: 16, // Increased font size
                          color: textColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                // Add website if available
                if (card.websiteUrl != null && card.websiteUrl!.isNotEmpty)
                  const SizedBox(height: 8),
                if (card.websiteUrl != null && card.websiteUrl!.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.language, color: textColor, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          card.websiteUrl ?? 'Website',
                          style: TextStyle(
                            fontSize: 16,
                            color: textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {String? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (trailing != null)
          Text(
            trailing,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required Color iconColor,
    required VoidCallback? onTap,
  }) {
    return SizedBox(
      height: 90,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48, // Reduced from 50
              height: 48, // Reduced from 50
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 10, // Reduced from 11
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: Colors.grey[600], size: 20),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isLast) Divider(height: 1, color: Colors.grey[200]),
      ],
    );
  }

  Widget _buildSocialButton({
    required String label,
    required String icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                label.substring(0, 1),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              // Use this instead if you have actual icons:
              // child: Image.asset(icon, width: 24, height: 24),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.purple[700],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingBar(
      BuildContext context, String label, double percent, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: LinearProgressIndicator(
                value: percent / 100,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 10,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text('${percent.toStringAsFixed(0)}%'),
        ],
      ),
    );
  }

  Widget _buildRatingButton(
      {required IconData icon, required String label, required Color color}) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

// Helper methods for parsing colors and determining text color
  Color? _parseColor(String? colorString, Color? defaultColor) {
    if (colorString == null || colorString.isEmpty) {
      return defaultColor;
    }
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return defaultColor;
    }
  }

  bool _isColorDark(Color color) {
    // Calculate the perceptive luminance (perceived brightness)
    // This formula gives a value between 0 and 255
    double luminance =
        (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return luminance < 0.5;
  }

// URL launcher methods
  void _launchPhone(String phoneNumber) {
    launchUrl(Uri.parse('tel:$phoneNumber'));
  }

  void _launchEmail(String email) {
    launchUrl(Uri.parse('mailto:$email'));
  }

  void _launchSms(String phoneNumber) {
    launchUrl(Uri.parse('sms:$phoneNumber'));
  }

  void _launchUrl(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    launchUrl(Uri.parse(url));
  }

  void _launchMaps(String address) {
    final encodedAddress = Uri.encodeComponent(address);
    launchUrl(Uri.parse('https://maps.google.com/?q=$encodedAddress'));
  }

  void _openOrganizationCard(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Fetch the organization's card information
      // This would typically be a database call to fetch the card by company name

      final CardProvider cardProvider =
          Provider.of<CardProvider>(context, listen: false);

      final String uuid = card.uuid ?? '';
      final organizationCard = await cardProvider.getCardByUuid(uuid: uuid);

      // Close loading dialog
      Navigator.pop(context);

      if (organizationCard != null) {
        // final bool isOwner = card.userUuid == organizationCard[];
        final bool isOwner = card.userUuid == organizationCard.userUuid;

        // Navigate to the organization's card details page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CardDetailsPage(
              card: organizationCard,
              currentUserId: card.userUuid,
              isFromShareLink: true,
            ),
          ),
        );

        // Show permission toast based on ownership
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isOwner
                  ? 'You have full access to this organization card'
                  : 'Viewing organization card in read-only mode',
            ),
            backgroundColor: isOwner ? Colors.green : Colors.blue,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        // Show error if organization card couldn't be found
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No card found for ${card.company}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog and show error
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading organization card: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
