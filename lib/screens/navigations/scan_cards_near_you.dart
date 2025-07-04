import 'package:ecard_app/components/custom_widgets.dart';
import 'package:flutter/material.dart';

import '../../utils/resources/strings/strings.dart';

class ScanCard {
  final String name;
  final String cardNumber;
  final double signalStrength;
  final double distance;
  final Color statusColor;

  ScanCard({
    required this.name,
    required this.cardNumber,
    required this.signalStrength,
    required this.distance,
    required this.statusColor,
  });
}

class ScanningScreen extends StatefulWidget {
  const ScanningScreen({super.key});

  @override
  State<ScanningScreen> createState() => _ScanningScreenState();
}

class _ScanningScreenState extends State<ScanningScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scanController;

  // Mock data commented out for later use
  /*
  List<ScanCard> nearbyCards = [
    ScanCard(
      name: 'Michael Anderson',
      cardNumber: 'EC-1263-15633',
      signalStrength: 87.0,
      distance: 2.2,
      statusColor: Colors.green,
    ),
    ScanCard(
      name: 'Sarah Johnson',
      cardNumber: 'EC-1632-1378',
      signalStrength: 51.0,
      distance: 4.8,
      statusColor: Colors.amber,
    ),
    ScanCard(
      name: 'David Williams',
      cardNumber: 'EC-3548-7782',
      signalStrength: 42.0,
      distance: 6.3,
      statusColor: Colors.amber,
    ),
  ];
  */

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).highlightColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const Spacer(),
              _buildCenterScanningIcon(),
              const Spacer(),
              _buildStartScanButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          HeaderBoldWidget(
              text: "Scan Cards",
              color: Theme.of(context).indicatorColor,
              size: '20.0'),
          IconButton(
            icon: Icon(
              Icons.refresh,
              size: 25,
              color: Theme.of(context).indicatorColor,
            ),
            onPressed: () {
              // Refresh logic
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCenterScanningIcon() {
    return Container(
      height: 300,
      alignment: Alignment.center,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseController, _scanController]),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulsing circle
              Opacity(
                opacity: (1 - _pulseController.value) * 0.3,
                child: Container(
                  width: 200 + (_pulseController.value * 50),
                  height: 200 + (_pulseController.value * 50),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              // Middle pulsing circle
              Opacity(
                opacity: (1 - (_pulseController.value * 0.8)) * 0.5,
                child: Container(
                  width: 150 + (_pulseController.value * 35),
                  height: 150 + (_pulseController.value * 35),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.6),
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              // Inner pulsing circle
              Opacity(
                opacity: (1 - (_pulseController.value * 0.6)) * 0.7,
                child: Container(
                  width: 100 + (_pulseController.value * 25),
                  height: 100 + (_pulseController.value * 25),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.8),
                      width: 2,
                    ),
                  ),
                ),
              ),

              // Scanning line
              Transform.rotate(
                angle: _scanController.value * 6.28, // 2 * pi for full rotation
                child: Container(
                  width: 120,
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                        Theme.of(context).primaryColor,
                      ],
                    ),
                  ),
                ),
              ),

              // Center icon container
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.radar,
                  color: Colors.white,
                  size: 35,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStartScanButton() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(30),
            ),
          ),
        ),
        child: Text(
          Texts.startScanning,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Commented out methods for later use when mock data is needed
  /*
  Widget _buildScannerAnimation() {
    return Container(
      height: 180,
      alignment: Alignment.center,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer circle
              Opacity(
                opacity: (1 - _pulseController.value) * 0.3,
                child: Container(
                  width: 160 + (_pulseController.value * 40),
                  height: 160 + (_pulseController.value * 40),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.6),
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              // Middle circle
              Opacity(
                opacity: (1 - (_pulseController.value * 0.8)) * 0.5,
                child: Container(
                  width: 120 + (_pulseController.value * 30),
                  height: 120 + (_pulseController.value * 30),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.8),
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              // Inner circle
              Opacity(
                opacity: (1 - (_pulseController.value * 0.6)) * 0.7,
                child: Container(
                  width: 80 + (_pulseController.value * 20),
                  height: 80 + (_pulseController.value * 20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              // Center wifi icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wifi,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNearbyCardsHeader() {
    return NormalHeaderWidget(
        text: "Nearby Cards",
        color: Theme.of(context).indicatorColor,
        size: '18.0');
  }

  Widget _buildNearbyCardsList() {
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: nearbyCards.length,
        itemBuilder: (context, index) {
          final card = nearbyCards[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              children: [
                // Card icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.credit_card,
                    color: Theme.of(context).primaryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                // Card info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color:
                              Theme.of(context).indicatorColor.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        card.cardNumber,
                        style: TextStyle(
                          color:
                              Theme.of(context).indicatorColor.withOpacity(0.3),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // Signal strength indicator
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 60,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: card.signalStrength / 100,
                              backgroundColor: Theme.of(context)
                                  .indicatorColor
                                  .withOpacity(0.3),
                              color: card.statusColor,
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${card.signalStrength.toInt()}%',
                          style: TextStyle(
                            color: Theme.of(context)
                                .indicatorColor
                                .withOpacity(0.2),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${card.distance} m away',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  */
}
