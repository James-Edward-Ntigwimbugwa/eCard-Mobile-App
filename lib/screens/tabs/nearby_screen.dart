import 'package:flutter/material.dart';
import 'package:ecard_app/components/custom_widgets.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ecard_app/modals/card_modal.dart';

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

  // This is used to prevent multiple scans of the same QR code
  String? lastScannedCode;
  DateTime? lastScanTime;

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      // Need to handle platform differences for camera
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).highlightColor,
      body: Stack(
        children: [
          // QR Scanner View
          _buildQrView(context),

          // Overlay UI
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
          // GestureDetector(
          //   onTap: () => Navigator.pop(context),
          //   child: Container(
          //     padding: const EdgeInsets.all(8.0),
          //     decoration: BoxDecoration(
          //       color: Colors.black.withOpacity(0.4),
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //     child: const Icon(
          //       Icons.arrow_back,
          //       color: Colors.white,
          //       size: 24,
          //     ),
          //   ),
          // ),
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
    // Get the screen size for scanner area adjustments
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

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!isScanning || scanData.code == null) return;

      // Prevent multiple scans of the same code within 2 seconds
      final now = DateTime.now();
      if (lastScannedCode == scanData.code &&
          lastScanTime != null &&
          now.difference(lastScanTime!).inSeconds < 2) {
        return;
      }

      lastScannedCode = scanData.code;
      lastScanTime = now;

      // Try to parse the QR code data
      if (_isValidECardQR(scanData.code!)) {
        setState(() {
          isScanning = false;
        });
        controller.pauseCamera();

        // Parse the QR code into a Card object
        final cardData = _parseCardData(scanData.code!);
        _showCardFoundSheet(cardData);
      } else {
        // Show invalid QR code message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Not a valid eCard QR code'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  bool _isValidECardQR(String data) {
    // Check if the QR has the expected format for an eCard
    final lines = data.split('\n');

    // Look for eCard specific data markers (ORG, TEL, EMAIL, etc.)
    bool hasOrgMarker = lines.any((line) => line.startsWith('ORG:'));
    bool hasTitleMarker = lines.any((line) => line.startsWith('TITLE:'));
    bool hasContactInfo = lines.any((line) =>
        line.startsWith('TEL:') ||
        line.startsWith('EMAIL:') ||
        line.startsWith('URL:'));

    return hasOrgMarker || (hasTitleMarker && hasContactInfo);
  }

  CustomCard _parseCardData(String qrData) {
    final lines = qrData.split('\n');
    String? company;
    String? title;
    String? phoneNumber;
    String? email;
    String? websiteUrl;
    String? address;

    for (var line in lines) {
      if (line.startsWith('ORG:')) {
        company = line.substring(4);
      } else if (line.startsWith('TITLE:')) {
        title = line.substring(6);
      } else if (line.startsWith('TEL:')) {
        phoneNumber = line.substring(4);
      } else if (line.startsWith('EMAIL:')) {
        email = line.substring(6);
      } else if (line.startsWith('URL:')) {
        websiteUrl = line.substring(4);
      } else if (line.startsWith('ADR:')) {
        address = line.substring(4);
      }
    }

    return CustomCard(
      title,
      uuid: 'scanned-card-${DateTime.now().millisecondsSinceEpoch}',
      company: company ?? 'Unknown Organization',
      phoneNumber: phoneNumber,
      email: email,
      websiteUrl: websiteUrl,
      address: address,
    );
  }

  void _showCardFoundSheet(CustomCard card) {
    final primaryColor = Theme.of(context).primaryColor;
    final screenWidth = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        width: screenWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 5,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Sheet Handle
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(50),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40), // For balance
                  Text(
                    'eCard Found!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        isScanning = true;
                      });
                      controller?.resumeCamera();
                    },
                  ),
                ],
              ),
            ),

            // Success Animation
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: primaryColor,
                size: 80,
              ),
            ),

            const SizedBox(height: 20),

            // Card Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  Text(
                    card.company ?? 'Organization',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  if (card.title != null)
                    Text(
                      card.title!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                  const SizedBox(height: 30),

                  // Contact information
                  if (card.phoneNumber != null)
                    _buildContactInfoRow(Icons.phone, card.phoneNumber!),
                  if (card.email != null)
                    _buildContactInfoRow(Icons.email, card.email!),
                  if (card.websiteUrl != null)
                    _buildContactInfoRow(Icons.language, card.websiteUrl!),
                  if (card.address != null)
                    _buildContactInfoRow(Icons.location_on, card.address!),

                  const SizedBox(height: 30),

                  // Save button
                  ElevatedButton.icon(
                    onPressed: () {
                      // Add logic to save the card
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Card saved successfully')),
                      );
                      Navigator.pop(context);
                      setState(() {
                        isScanning = true;
                      });
                      controller?.resumeCamera();
                    },
                    icon: const Icon(Icons.save_alt),
                    label: const Text('Save to My Cards'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // New: See more button with organization name
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to more details about the organization
                      if (card.websiteUrl != null) {
                        _launchUrl(card.websiteUrl!);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('No website information available')),
                        );
                      }
                    },
                    icon: const Icon(Icons.info_outline),
                    label: Text(
                        'See more about ${card.company ?? "this Organization"}'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: BorderSide(color: primaryColor),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      // Resume camera when sheet is closed
      if (mounted) {
        setState(() {
          isScanning = true;
        });
        controller?.resumeCamera();
      }
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
    // This would need a separate package like image_picker
    // For simplicity, we'll just show a message
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
