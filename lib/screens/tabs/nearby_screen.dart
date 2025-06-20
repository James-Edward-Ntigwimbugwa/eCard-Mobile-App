import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:ecard_app/components/alert_reminder.dart';
import 'package:ecard_app/services/card_request_implementation.dart';
import 'package:ecard_app/utils/resources/animes/lottie_animes.dart';
import 'package:flutter/material.dart';
import 'package:ecard_app/components/custom_widgets.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ecard_app/modals/card_modal.dart';

import '../../components/found_card.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isScanning = true;
  bool flashOn = false;
  bool isSaving = false;

  String? lastScannedCode;
  DateTime? lastScanTime;

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.resumeCamera();
    }
  }

  bool isNumeric(String s) {
    return int.tryParse(s) != null;
  }

  void _saveCardLogic(String userId, String cardId) async {
    debugPrint("method savecardLogic in nearbyscreen executed ====>");
    if (isSaving && mounted) {
      Alerts.showLoader(
        context: context,
        message: "Saving Card ...",
        icon: LoadingAnimationWidget.stretchedDots(
          color: Theme.of(context).primaryColor,
          size: 20,
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
    } on TimeoutException catch (e) {
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
    } on SocketException catch (e) {
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
      if (isSaving && mounted) {
        Navigator.pop(context); // Dismiss the loader
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).highlightColor,
      body: Stack(
        children: [
          _buildQrView(context),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const Spacer(),
                _buildScannerGuide(),
                const Spacer(),
                _buildBottomControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          HeaderBoldWidget(
            text: "Scan eCard",
            color: Colors.white,
            size: '20.0',
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                flashOn = !flashOn;
              });
              controller?.toggleFlash();
            },
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                flashOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = MediaQuery.of(context).size.width * 0.7;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Theme.of(context).primaryColor,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  Widget _buildScannerGuide() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            "Position QR code within the frame to scan",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              shadows: [
                Shadow(
                  blurRadius: 8.0,
                  color: Colors.black.withOpacity(0.5),
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      color: Colors.black.withOpacity(0.4),
      child: Column(
        children: [
          Text(
            "Scan only eCard QR codes",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: Icons.image,
                label: "Gallery",
                onTap: _scanFromGallery,
              ),
              _buildControlButton(
                icon: Icons.refresh,
                label: "Reset",
                onTap: () {
                  setState(() {
                    isScanning = true;
                    lastScannedCode = null;
                  });
                  controller?.resumeCamera();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController ctrl) {
    controller = ctrl;
    controller!.scannedDataStream.listen((scanData) {
      if (!isScanning) return;
      isScanning = false;

      String qrData = scanData.code ?? '';
      String? id;
      String? uuid;
      String? title;
      String? company;
      String? organization;
      String? phoneNumber;
      String? email;
      String? websiteUrl;
      String? backgroundColor;
      String? fontColor;

      // Try JSON parsing first
      try {
        final jsonData = jsonDecode(qrData);
        if (jsonData is Map<String, dynamic>) {
          // Include uuid as a fallback for id
          id = jsonData['id']?.toString() ??
              jsonData['ID']?.toString() ??
              jsonData['cardId']?.toString() ??
              jsonData['card_id']?.toString() ??
              jsonData['uuid']?.toString();

          uuid = jsonData['uuid']?.toString();
          title = jsonData['title']?.toString();
          company = jsonData['company']?.toString();
          organization = jsonData['organization']?.toString();
          phoneNumber = jsonData['phoneNumber']?.toString();
          email = jsonData['email']?.toString();
          websiteUrl = jsonData['websiteUrl']?.toString();
          backgroundColor = jsonData['backgroundColor']?.toString();
          fontColor = jsonData['fontColor']?.toString();

          if (id == null) {
            debugPrint(
                "WARNING: JSON found but no 'id' or 'uuid' field. Falling back to line-by-line parsing.");
          }
        }
      } catch (e) {
        debugPrint('Not JSON format, parsing as line-by-line');
      }

      // Fallback: line-by-line parsing
      if (id == null) {
        final lines = qrData.split('\n');
        for (var line in lines) {
          line = line.trim();
          String upperLine = line.toUpperCase();

          if (upperLine.startsWith('ID:')) {
            id = line.substring(3).trim();
          } else if (upperLine.startsWith('CARDID:')) {
            id = line.substring(7).trim();
          } else if (upperLine.startsWith('CARD_ID:')) {
            id = line.substring(8).trim();
          } else if (upperLine.startsWith('CARD-ID:')) {
            id = line.substring(7).trim();
          } else if (upperLine.startsWith('UUID:')) {
            uuid = line.substring(5).trim();
            if (id == null) id = uuid;
          } else if (upperLine.startsWith('TITLE:')) {
            title = line.substring(6).trim();
          } else if (upperLine.startsWith('ORG:')) {
            organization = line.substring(4).trim();
          } else if (upperLine.startsWith('COMPANY:')) {
            company = line.substring(8).trim();
          } else if (upperLine.startsWith('TEL:')) {
            phoneNumber = line.substring(4).trim();
          } else if (upperLine.startsWith('EMAIL:')) {
            email = line.substring(6).trim();
          } else if (upperLine.startsWith('URL:')) {
            websiteUrl = line.substring(4).trim();
          } else if (upperLine.startsWith('BGCOLOR:')) {
            backgroundColor = line.substring(8).trim();
          } else if (upperLine.startsWith('FONTCOLOR:')) {
            fontColor = line.substring(10).trim();
          }

          if (id != null && title != null && company != null) break;
        }
      }

      debugPrint("Final parsed ID: '$id'");

      final card = CustomCard(
        null,
        title ?? 'Scanned Card',
        id: id ?? 'unknown-card-id',
        uuid: uuid ?? 'scanned-card-${DateTime.now().millisecondsSinceEpoch}',
        company: company,
        organization: organization ?? company ?? 'Unknown Organization',
        phoneNumber: phoneNumber,
        email: email,
        websiteUrl: websiteUrl,
        backgroundColor: backgroundColor,
        fontColor: fontColor,
      );

      _showCardFoundSheet(card);
    });
  }

  bool _isValidECardQR(String data) {
    final lines = data.split('\n');
    bool hasOrgMarker = lines.any((line) => line.startsWith('ORG:'));
    bool hasTitleMarker = lines.any((line) => line.startsWith('TITLE:'));
    bool hasContactInfo = lines.any((line) =>
        line.startsWith('TEL:') ||
        line.startsWith('EMAIL:') ||
        line.startsWith('URL:'));
    return hasOrgMarker || (hasTitleMarker && hasContactInfo);
  }

  // Updated _parseCardData method - replace the existing one in your nearby_screen.dart

  CustomCard _parseCardData(String qrData) {
    final lines = qrData.split('\n');

    // Debug the raw QR data
    debugPrint("=== QR Code Raw Data ===");
    debugPrint(qrData);
    debugPrint("========================");

    String? company;
    String? title;
    String? phoneNumber;
    String? email;
    String? websiteUrl;
    String? address;
    String? id;
    String? uuid;
    String? organization;
    String? cardDescription;
    String? profilePhoto;
    String? department;
    String? linkedIn;
    String? backgroundColor;
    String? fontColor;

    // Try to parse as JSON first (in case QR contains JSON)
    try {
      final jsonData = jsonDecode(qrData);
      if (jsonData is Map<String, dynamic>) {
        id = jsonData['id']?.toString() ??
            jsonData['ID']?.toString() ??
            jsonData['cardId']?.toString() ??
            jsonData['card_id']?.toString();

        if (id != null) {
          debugPrint("Found ID from JSON: '$id'");
          // Parse other fields from JSON if needed
          title = jsonData['title']?.toString();
          company =
              jsonData['company']?.toString() ?? jsonData['org']?.toString();
          email = jsonData['email']?.toString();
          phoneNumber =
              jsonData['phone']?.toString() ?? jsonData['tel']?.toString();
          websiteUrl =
              jsonData['websiteUrl']?.toString() ?? jsonData['url']?.toString();
          address =
              jsonData['address']?.toString() ?? jsonData['adr']?.toString();
          uuid = jsonData['uuid']?.toString();
          organization = jsonData['organization']?.toString();
          cardDescription = jsonData['cardDescription']?.toString() ??
              jsonData['desc']?.toString();
          profilePhoto = jsonData['profilePhoto']?.toString() ??
              jsonData['photo']?.toString();
          department = jsonData['department']?.toString() ??
              jsonData['dept']?.toString();
          linkedIn = jsonData['linkedin']?.toString() ??
              jsonData['linkedIn']?.toString();
          backgroundColor = jsonData['backgroundColor']?.toString() ??
              jsonData['bgColor']?.toString();
          fontColor = jsonData['fontColor']?.toString();
        } else {
          debugPrint(
              "JSON found, but no 'id' field present. Falling back to line-by-line parsing.");
        }
      }
    } catch (e) {
      debugPrint("Not JSON format, parsing as line-by-line");
    }

    // If not found in JSON, try line-by-line parsing
    if (id == null) {
      for (var line in lines) {
        line = line.trim();
        String upperLine = line.toUpperCase();

        // Try multiple possible ID field formats
        if (upperLine.startsWith('ID:')) {
          id = line.substring(3).trim();
          debugPrint("Found ID: '$id'");
          break;
        } else if (upperLine.startsWith('CARDID:')) {
          id = line.substring(7).trim();
          debugPrint("Found CARDID: '$id'");
          break;
        } else if (upperLine.startsWith('CARD_ID:')) {
          id = line.substring(8).trim();
          debugPrint("Found CARD_ID: '$id'");
          break;
        } else if (upperLine.startsWith('CARD-ID:')) {
          id = line.substring(8).trim();
          debugPrint("Found CARD-ID: '$id'");
          break;
        }
      }

      // Parse other fields
      for (var line in lines) {
        line = line.trim();

        if (line.startsWith('UUID:')) {
          uuid = line.substring(5).trim();
          debugPrint("======== card uuid ========= $uuid =====");
        } else if (line.startsWith('TITLE:')) {
          title = line.substring(6).trim();
        } else if (line.startsWith('ORG:')) {
          company = line.substring(4).trim();
        } else if (line.startsWith('ORGANIZATION:')) {
          organization = line.substring(13).trim();
        } else if (line.startsWith('TEL:')) {
          phoneNumber = line.substring(4).trim();
        } else if (line.startsWith('EMAIL:')) {
          email = line.substring(6).trim();
        } else if (line.startsWith('URL:')) {
          websiteUrl = line.substring(4).trim();
        } else if (line.startsWith('ADR:')) {
          address = line.substring(4).trim();
        } else if (line.startsWith('DESC:')) {
          cardDescription = line.substring(5).trim();
        } else if (line.startsWith('PHOTO:')) {
          profilePhoto = line.substring(6).trim();
        } else if (line.startsWith('DEPT:')) {
          department = line.substring(5).trim();
        } else if (line.startsWith('LINKEDIN:')) {
          linkedIn = line.substring(9).trim();
        } else if (line.startsWith('BGCOLOR:')) {
          backgroundColor = line.substring(8).trim();
        } else if (line.startsWith('FONTCOLOR:')) {
          fontColor = line.substring(10).trim();
        }
      }
    }

    debugPrint("Final parsed ID: '$id'");

    // **IMPORTANT**: If no ID found, provide a default or handle appropriately
    // You should modify your QR generation to include ID:1 or handle this case
    if (id == null) {
      debugPrint(
          "WARNING: No ID found in QR code. You need to add 'ID:1' to your QR generation.");
      // You can either:
      // 1. Use a default ID (not recommended for production)
      // id = "1"; // This is just for testing

      // 2. Or show an error to the user
      debugPrint("ERROR: QR code must contain an ID field");
    }

    // Validate that we have a proper numeric ID
    if (id != null && !isNumeric(id)) {
      debugPrint("Warning: ID '$id' is not numeric");
    }

    return CustomCard(
      null, // userUuid - will be set when saving
      title ?? 'Scanned Card',
      id: id ?? 'unknown-card-id', // Keep this as fallback
      uuid: uuid ?? 'scanned-card-${DateTime.now().millisecondsSinceEpoch}',
      company: company,
      organization: organization ?? company ?? 'Unknown Organization',
      phoneNumber: phoneNumber,
      email: email,
      websiteUrl: websiteUrl,
      address: address,
      cardDescription: cardDescription,
      profilePhoto: profilePhoto,
      department: department,
      linkedIn: linkedIn,
      backgroundColor: backgroundColor,
      fontColor: fontColor,
      active: true,
      publishCard: false,
    );
  }

  void _showCardFoundSheet(CustomCard card) {
    showModalBottomSheet(
      context: context,
      builder: (_) => FoundCard(card: card),
    ).whenComplete(() {
      setState(() {
        isScanning = true;
      });
    });
  }

  Widget _buildContactInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _scanFromGallery() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gallery scan would be implemented here'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No camera permission')),
      );
    }
  }

  void _launchUrl(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    launchUrl(Uri.parse(url));
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
