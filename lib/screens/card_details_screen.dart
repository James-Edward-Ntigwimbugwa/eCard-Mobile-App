import 'dart:ui';
import 'package:ecard_app/components/alert_reminder.dart';
import 'package:ecard_app/components/custom_widgets.dart';
import 'package:ecard_app/services/cad_service.dart';
import 'package:ecard_app/utils/resources/animes/lottie_animes.dart';
import 'package:ecard_app/utils/resources/strings/strings.dart';
import 'package:flutter/material.dart';
import 'package:ecard_app/modals/card_modal.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../components/card_display_widget.dart';

class CardDetailsPage extends StatefulWidget{
    final CustomCard card;
  final String? currentUserId;
  final bool isFromShareLink;

  const CardDetailsPage({
    super.key,
    required this.card,
    required this.currentUserId,
    required this.isFromShareLink,
  });

  @override
  State<StatefulWidget> createState() => _CardDetailsPageState();
  
}

class _CardDetailsPageState extends State<CardDetailsPage> {
  bool _isDeleting = false;

  void showLoader() => Alerts.showLoader(
      context: context,
      message: Loaders.loading,
      icon: Lottie.asset(
        LottieAnimes.loading,
        width: 130,
        height: 130,
        fit: BoxFit.contain,
      ));

  // Helper method to show error messages
  void showErrorMessage(String message) {
    Alerts.showError(
      context: context,
      message: message,
      icon: Lottie.asset(
        LottieAnimes.errorLoader,
        width: 130,
        height: 130,
        fit: BoxFit.contain,
      ),
    );
  }

  // Helper method to show network error messages
  void showNetworkError(String message) {
    Alerts.showError(
      context: context,
      message: message,
      icon: Lottie.asset(
        LottieAnimes.errorLoader,
        width: 130,
        height: 130,
        fit: BoxFit.contain,
      ),
    );
  }

  // Helper method to show success message
  void showSuccessMessage(String message) {
    Alerts.showSuccess(
      context: context,
      message: message,
      icon: Lottie.asset(
        LottieAnimes.successLoader,
        width: 130,
        height: 130,
        fit: BoxFit.contain,
      ),
    );
  }

  Future<void> _deleteCard({required String? cardId}) async {
    if (!mounted) return;
    try {
      showLoader();
      final response = await CardProvider.deleteCard(cardId: cardId)
          .timeout(const Duration(seconds: 10), onTimeout: () {
        Navigator.pop(context); 
        showErrorMessage("Request timed out");
        throw Exception("Request timed out");
      });
      Navigator.pop(context);
      if (response == true) {
        showSuccessMessage("Card Deleted");
        Navigator.pop(context); 
      } else {
        showErrorMessage("Failed to delete Card");
      }
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context); 
      }
      showErrorMessage(e.toString());
      debugPrint("An error occurred in deleteCard: $e");
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
    final primaryColor = Theme.of(context).primaryColor;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).highlightColor,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: (screenHeight * 0.4) + 20,
              floating: false,
              pinned: true,
              backgroundColor: Theme.of(context).highlightColor,
              foregroundColor: Theme.of(context).highlightColor,
              elevation: 0,
              leading: Container(
                margin: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).indicatorColor.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Theme.of(context).indicatorColor,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
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
                  ? Text(
                      widget.card.title ?? 'Card Details',
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                    )
                  : null,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.only(top: 80.0),
                  child: Container(
                    color: Theme.of(context).highlightColor,
                    child: CardDisplayWidget(
                      card: widget.card,
                      onCardTap: (card) {},
                      onShare: (card) => _showShareModal(context),
                    ),
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
                height: 120,
                child: GridView.count(
                  padding: const EdgeInsets.only(top: 10),
                  crossAxisCount: 5,
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
                      onTap: () => widget.card.phoneNumber != null
                          ? _launchPhone(widget.card.phoneNumber!)
                          : null,
                    ),
                    _buildActionButton(
                      context,
                      icon: Icons.email,
                      label: 'Email',
                      color: primaryColor.withOpacity(0.6),
                      iconColor: Colors.white,
                      onTap: () =>
                          widget.card.email != null ? _launchEmail(widget.card.email!) : null,
                    ),
                    _buildActionButton(
                      context,
                      icon: Icons.message,
                      label: 'Message',
                      color: primaryColor.withOpacity(0.6),
                      iconColor: Colors.white,
                      onTap: () => widget.card.phoneNumber != null
                          ? _launchSms(widget.card.phoneNumber!)
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
              _buildSectionHeader(context, 'Contact Information'),
              const SizedBox(height: 8),
              Card(
                color: Theme.of(context).secondaryHeaderColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (widget.card.phoneNumber != null &&
                          widget.card.phoneNumber!.isNotEmpty)
                        _buildContactItem(
                          icon: Icons.phone,
                          title: 'Phone',
                          value: widget.card.phoneNumber!,
                          onTap: () => _launchPhone(widget.card.phoneNumber!), context: context,
                        ),
                      if (widget.card.email != null &&widget.card.email!.isNotEmpty)
                        _buildContactItem(
                          icon: Icons.email,
                          title: 'Email',
                          value: widget.card.email!,
                          onTap: () => _launchEmail(widget.card.email!), context: context,
                        ),
                      if (widget.card.websiteUrl != null &&
                          widget.card.websiteUrl!.isNotEmpty)
                        _buildContactItem(
                          icon: Icons.language,
                          title: 'Website',
                          value: widget.card.websiteUrl!,
                          onTap: () => _launchUrl(widget.card.websiteUrl!), context: context,
                        ),
                      if (widget.card.address != null && widget.card.address!.isNotEmpty)
                        _buildContactItem(
                          icon: Icons.location_on,
                          title: 'Address',
                          value: widget.card.address!,
                          onTap: () => _launchMaps(widget.card.address!),
                          isLast: true, context: context,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Social Media Section
              _buildSectionHeader(context, 'Social Media'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color:Theme.of(context).secondaryHeaderColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSocialButton(
                      label: 'LinkedIn',
                      icon: Icon(
                        FontAwesomeIcons.linkedinIn,
                      ),
                      color: Colors.blue.shade700,
                      onTap: () => widget.card.linkedIn != null
                          ? _launchUrl(widget.card.linkedIn!)
                          : null,
                    ),
                    _buildSocialButton(
                      label: 'Twitter',
                      icon: Icon(
                        FontAwesomeIcons.twitter,
                      ),
                      color: Colors.blue.shade400,
                      onTap: () {},
                    ),
                    _buildSocialButton(
                      label: 'Instagram',
                      icon: Icon(
                        FontAwesomeIcons.instagram,
                      ),
                      color: Colors.pink,
                      onTap: () {},
                    ),
                    _buildSocialButton(
                      label: 'Facebook',
                      icon: Icon(
                        FontAwesomeIcons.facebook,
                      ),
                      color: Colors.blue.shade900,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Card Analytics
              _buildSectionHeader(context, 'Card Analytics', trailing: 'Last 30 days'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).secondaryHeaderColor,
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
              _buildSectionHeader(context, 'Ratings'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).secondaryHeaderColor,
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
              _buildSectionHeader(context, 'Rate This Card'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color:Theme.of(context).secondaryHeaderColor,
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
              const Divider(
                height: 1,
              ),
              // Delete Card Button
              Container(
                padding: const EdgeInsets.only(top: 10.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: ()=>{
                      _showDeleteDialog(context)
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Theme.of(context).indicatorColor,
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      shadowColor: Colors.red.withOpacity(0.3),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      size: 24,
                      color: Theme.of(context).indicatorColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _showShareModal(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final screenWidth = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          ),
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
                                    embeddedImage: widget.card.profilePhoto != null
                                        ? NetworkImage(widget.card.profilePhoto!)
                                            as ImageProvider
                                        : null,
                                    embeddedImageStyle: QrEmbeddedImageStyle(
                                      size: const Size(40, 40),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  'Scan to view ${widget.card.title ?? "this card"}',
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
                                  icon: FontAwesomeIcons.message,
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
                                  icon: FontAwesomeIcons.facebook,
                                  color: Colors.blue.shade900,
                                  label: 'Facebook',
                                  onTap: () => _shareViaSocialMedia('facebook'),
                                ),
                                _buildShareOption(
                                  context,
                                  icon: FontAwesomeIcons.link,
                                  color: Colors.purple,
                                  label: 'Copy Link',
                                  onTap: () => _copyCardLink(context),
                                ),
                                _buildShareOption(
                                  context,
                                  icon: FontAwesomeIcons.share,
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
              width: 48,
              height: 48,
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
                  fontSize: 10,
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
    String qrData = '';
    if (widget.card.id != null && widget.card.id!.isNotEmpty) {
      qrData += 'ID:${widget.card.id}\n';
    }
    if (widget.card.uuid != null && widget.card.uuid!.isNotEmpty) {
      qrData += 'UUID:${widget.card.uuid}\n';
    }
    if (widget.card.company != null && widget.card.company!.isNotEmpty) {
      qrData += 'ORG:${widget.card.company}\n';
    }
    if (widget.card.organization != null && widget.card.organization!.isNotEmpty) {
      qrData += 'ORGANIZATION:${widget.card.organization}\n';
    }
    if (widget.card.title != null && widget.card.title!.isNotEmpty) {
      qrData += 'TITLE:${widget.card.title}\n';
    }
    if (widget.card.department != null && widget.card.department!.isNotEmpty) {
      qrData += 'DEPT:${widget.card.department}\n';
    }
    if (widget.card.phoneNumber != null && widget.card.phoneNumber!.isNotEmpty) {
      qrData += 'TEL:${widget.card.phoneNumber}\n';
    }
    if (widget.card.email != null && widget.card.email!.isNotEmpty) {
      qrData += 'EMAIL:${widget.card.email}\n';
    }
    if (widget.card.websiteUrl != null && widget.card.websiteUrl!.isNotEmpty) {
      qrData += 'URL:${widget.card.websiteUrl}\n';
    }
    if (widget.card.address != null && widget.card.address!.isNotEmpty) {
      qrData += 'ADR:${widget.card.address}\n';
    }
    if (widget.card.linkedIn != null && widget.card.linkedIn!.isNotEmpty) {
      qrData += 'LINKEDIN:${widget.card.linkedIn}\n';
    }
    if (widget.card.cardDescription != null && widget.card.cardDescription!.isNotEmpty) {
      qrData += 'DESC:${widget.card.cardDescription}\n';
    }
    if (widget.card.profilePhoto != null && widget.card.profilePhoto!.isNotEmpty) {
      qrData += 'PHOTO:${widget.card.profilePhoto}\n';
    }
    if (widget.card.backgroundColor != null && widget.card.backgroundColor!.isNotEmpty) {
      qrData += 'BGCOLOR:${widget.card.backgroundColor}\n';
    }
    if (widget.card.fontColor != null && widget.card.fontColor!.isNotEmpty) {
      qrData += 'FONTCOLOR:${widget.card.fontColor}\n';
    }
    qrData += 'ACTIVE:${widget.card.active}\n';
    qrData += 'PUBLISHED:${widget.card.publishCard}\n';
    return qrData.isEmpty ? 'No card data available' : qrData;
  }

  void _shareViaSms() {
    if (widget.card.phoneNumber != null) {
      final message = 'Check out ${widget.card.title}\'s business card!';
      final Uri uri = Uri.parse('sms:?body=$message');
      launchUrl(uri);
    }
  }

  void _shareViaEmail() {
    if (widget.card.email != null) {
      final subject = 'Business Card: ${widget.card.title ?? "Contact"}';
      final body = 'Please find attached the business card for ${widget.card.title}.';
      final Uri uri = Uri.parse('mailto:?subject=$subject&body=$body');
      launchUrl(uri);
    }
  }

  void _shareViaSocialMedia(String platform) {
    // Implementation depends on what social media integrations you have
  }

  void _copyCardLink(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Card link copied to clipboard')),
    );
  }

  void _shareViaSystem() {
    // Implementation would use platform share dialog
  }

  Widget _buildSectionHeader(BuildContext context, String title, {String? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
            style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).indicatorColor,
          ),
        ),
        if (trailing != null)
          Text(
            trailing,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).indicatorColor.withOpacity(0.7),
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
              width: 48,
              height: 48,
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
                style:  TextStyle(
                  color: Theme.of(context).indicatorColor,
                  fontSize: 10,
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
    required BuildContext context,
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
                          color: Theme.of(context).indicatorColor,
                        ),
                      ),
                      Text(
                        value,
                        style: TextStyle(
                          color: Theme.of(context).indicatorColor.withOpacity(0.8),
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
    required Icon icon,
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
          SizedBox(width: 80, child: Text(label , 
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).indicatorColor,
            ),
          )),
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
    double luminance =
        (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return luminance < 0.5;
  }

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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final CardProvider cardProvider =
          Provider.of<CardProvider>(context, listen: false);
      final String uuid = widget.card.uuid ?? '';
      final organizationCard = await cardProvider.getCardByUuid(uuid: uuid);
      Navigator.pop(context);

      if (organizationCard != null) {
        final bool isOwner = widget.card.userUuid == organizationCard.userUuid;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CardDetailsPage(
              card: organizationCard,
              currentUserId: widget.card.userUuid,
              isFromShareLink: true,
            ),
          ),
        );
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
        Alerts.showError(
            context: context,
            message: "No card found for this organization",
            icon: Lottie.asset(LottieAnimes.errorLoader,
                height: 120, width: 120));
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading organization card: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).highlightColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          height: 220,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HeaderBoldWidget(
                  text: "Are you Sure?",
                  color: Theme.of(context).primaryColor,
                  size: '20.0'),
              const SizedBox(height: 12),
              Text(
                "Upon deleting your card, you will lose all your card data and it cannot be recovered.",
                textAlign: TextAlign.center,
                style: GoogleFonts.aBeeZee(
                    textStyle: TextStyle(
                        color: Theme.of(context).indicatorColor,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: HeaderBoldWidget(
                            text: "Cancel",
                            color: Theme.of(context).primaryColor,
                            size: '18.0')),
                  ),
                  SizedBox(
                    height: 24,
                    child: VerticalDivider(
                        width: 20, color: Theme.of(context).indicatorColor),
                  ),
                  Expanded(
                    child: TextButton(
                        onPressed: () {
                          _deleteCard(cardId: widget.card.id);
                          Navigator.pop(context);
                        },
                        child: HeaderBoldWidget(
                            text: "Delete",
                            color: Theme.of(context).primaryColor,
                            size: '18.0')),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
