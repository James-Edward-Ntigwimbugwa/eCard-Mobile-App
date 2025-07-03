import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../modals/card_modal.dart';
import '../services/cad_service.dart';
import '../utils/resources/animes/lottie_animes.dart';
import 'alert_reminder.dart';

class FoundCard extends StatefulWidget {
  final CustomCard card;
  final VoidCallback? onSeeMore;

  const FoundCard({
    super.key,
    required this.card,
    this.onSeeMore,
  });

  @override
  State<FoundCard> createState() => _FoundCardState();
}

class _FoundCardState extends State<FoundCard> {

  @override
  void initState() {
    super.initState();
  }

  void _saveCardLogic(BuildContext context, String? userId, String? cardId) async {
    debugPrint("method savecardLogic in nearbyscreen executed ====>");
    if (mounted) {
      Alerts.showLoader(
        context: context,
        message: "Saving Card ...",
        icon: Lottie.asset(LottieAnimes.loading, 
          width: 50,
          height: 50,
          fit: BoxFit.fill,
        ),
      );
    }

    final cardProvider = Provider.of<CardProvider>(context, listen: false);

    try {
      bool success = await cardProvider
          .saveOrganizationCard(userId: userId, cardId: cardId)
          .timeout(Duration(seconds: 20), onTimeout: () {
        throw TimeoutException("The operation timed out");
      });

      if (success) {
        Alerts.showSuccess(
          context: context,
          message: "Card Saved Successfully",
          icon: Text(LottieAnimes.successLoader),
        );

        Timer(const Duration(seconds: 2), () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context); // Close success dialog
          }
          Navigator.pop(context);
        });
      } else {
        Alerts.showError(
          context: context,
          message: "Failed to save card. Please try again",
          icon: Text(LottieAnimes.errorLoader),
        );

        Timer(const Duration(seconds: 2), () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context); // Close error dialog
          }
          Navigator.pop(context);
        });
      }
    } on TimeoutException {
      Alerts.showError(
        context: context,
        message: "Operation timed out. Please try again later.",
        icon: Text(LottieAnimes.errorLoader),
      );
      Timer(const Duration(seconds: 2), () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context); // Close error dialog
        }
        Navigator.pop(context);
      });
    } on SocketException {
      Alerts.showError(
        context: context,
        message: "Network error. Please check your connection.",
        icon: Text(LottieAnimes.errorLoader),
      );
      Timer(const Duration(seconds: 2), () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context); // Close error dialog
        }
        Navigator.pop(context);
      });
    } catch (e) {
      Alerts.showError(
        context: context,
        message: "An unexpected error occurred: ${e.toString()}",
        icon: Text(LottieAnimes.errorLoader),
      );
      Timer(const Duration(seconds: 2), () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context); // Close error dialog
        }
        Navigator.pop(context);
      });
    } finally {
      if (mounted) {
      }
      if (Navigator.canPop(context)) {
        // Ensure loader is popped only if it's the current route
        Navigator.pop(context); // Dismiss the loader
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    debugPrint("============ Found Card Details ========"
        " ${widget.card.id} \n  , ${widget.card.uuid} \n , ${widget.card.organization} \n "
        "===================================================");
    return Container(
        width: screenWidth,
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.85, // Limit height to 85% of screen
        ),
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
        child: SingleChildScrollView(
          child: Padding(
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
                  widget.card.company ?? widget.card.title ?? 'Organization',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),

                // Subtitle (Title if company exists, otherwise show ID)
                if (widget.card.company != null && widget.card.title != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      widget.card.title!,
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
                    _buildContactInfoRow(
                        Icons.credit_card, 'ID: ${widget.card.id}'),
                    if (widget.card.organization != null)
                      _buildContactInfoRow(
                          Icons.business, widget.card.organization!),
                    if (widget.card.phoneNumber != null)
                      _buildContactInfoRow(
                          Icons.phone, widget.card.phoneNumber!),
                    if (widget.card.email != null)
                      _buildContactInfoRow(Icons.email, widget.card.email!),
                    if (widget.card.websiteUrl != null)
                      _buildWebsiteRow(widget.card.websiteUrl!),
                  ],
                ),

                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          final String? userId = prefs.getString("userId");
                          _saveCardLogic(
                              context, userId, widget.card.id);
                        },
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
                        onPressed: widget.onSeeMore,
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
              ],
            ),
          ),
        ));
  }

  Widget _buildContactInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.grey.shade600,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
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
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.language,
              color: Colors.grey.shade600,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
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
                  fontSize: 14,
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
