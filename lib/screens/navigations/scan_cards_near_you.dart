import 'package:ecard_app/components/custom_widgets.dart';
import 'package:ecard_app/models/nearby_cards_spatial_data_model.dart';
import 'package:ecard_app/providers/location_provider.dart';
import 'package:ecard_app/screens/nearby_scanned_card_details_screen.dart';
import 'package:ecard_app/services/device_proximity_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/resources/strings/strings.dart';

enum ScanningState { idle, fetchingLocation, searchingCards, completed, error }

class ScanningScreen extends StatefulWidget {
  const ScanningScreen({super.key});

  @override
  State<ScanningScreen> createState() => _ScanningScreenState();
}

class _ScanningScreenState extends State<ScanningScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scanController;
  late AnimationController _distanceController;

  ScanningState _currentState = ScanningState.idle;
  String _statusText = '';
  List<BusinessCard> _foundCards = [];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _distanceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  void _handleLocationPermissionAndScanning() async {
    try {
      setState(() {
        _currentState = ScanningState.fetchingLocation;
        _statusText = 'Fetching your location...';
      });

      _pulseController.repeat();
      _scanController.repeat();

      var status = await Permission.location.status;

      if (!status.isGranted) {
        status = await Permission.location.request();
      }

      if (status.isGranted) {
        await _fetchLocationAndStartScanning();
      } else {
        _showPermissionDialog();
        _stopAnimations();
      }
    } catch (e) {
      setState(() {
        _currentState = ScanningState.error;
        _statusText = 'Error occurred during scanning';
      });
      _stopAnimations();
      var status = await Permission.location.status;
      if (status.isDenied || status.isRestricted) {
        _showPermissionDialog();
      }
    }
  }

  Future<void> _fetchLocationAndStartScanning() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Update status to searching
      setState(() {
        _currentState = ScanningState.searchingCards;
        _statusText = 'Searching for cards...';
      });

      String? address;
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          List<String> addressParts = [];

          if (place.subLocality != null && place.subLocality!.isNotEmpty) {
            addressParts.add(place.subLocality!);
          }
          if (place.locality != null && place.locality!.isNotEmpty) {
            addressParts.add(place.locality!);
          }
          if (place.administrativeArea != null &&
              place.administrativeArea!.isNotEmpty) {
            addressParts.add(place.administrativeArea!);
          }
          if (place.country != null && place.country!.isNotEmpty) {
            addressParts.add(place.country!);
          }

          address = addressParts.join(', ');
        }
      } catch (e) {
        address = "Address not available";
      }

      final locationProvider =
          Provider.of<LocationProvider>(context, listen: false);
      locationProvider.updateLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      );

      final deviceProximityService =
          Provider.of<DeviceProximityService>(context, listen: false);

      final prefs = await SharedPreferences.getInstance();
      final String? userUuid = prefs.getString('userUuid');

      await deviceProximityService.getNearbyDevices(
        userUuid: userUuid,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (deviceProximityService.hasSuccess) {
        List<BusinessCard> cards = deviceProximityService.nearbyDevices ?? [];

        setState(() {
          _currentState = ScanningState.completed;
          _statusText = 'Found ${cards.length} cards nearby';
          _foundCards = cards;
        });

        _stopAnimations();
        _distanceController.forward();

        debugPrint(
            "Scanning completed: ${deviceProximityService.successMessage}");
      } else if (deviceProximityService.hasError) {
        setState(() {
          _currentState = ScanningState.error;
          _statusText = 'Error: ${deviceProximityService.errorMessage}';
        });
        _stopAnimations();
        debugPrint(
            "Scanning completed: ${deviceProximityService.successMessage}");
        ("Scanning failed: ${deviceProximityService.errorMessage}");
      }
    } catch (e) {
      setState(() {
        _currentState = ScanningState.error;
        _statusText = 'Error fetching location: $e';
      });
      _stopAnimations();
      debugPrint("Error fetching location: $e");
    }
  }

  void _stopAnimations() {
    _pulseController.stop();
    _scanController.stop();
  }

  void _resetScanning() {
    setState(() {
      _currentState = ScanningState.idle;
      _statusText = '';
      _foundCards = [];
    });
    _stopAnimations();
    _distanceController.reset();
  }

  void _showPermissionDialog() {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Location Permission Required'),
          content: Text('Please enable location permission to scan cards.'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              child: Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  Color _getDistanceColor(double distance) {
    if (distance <= 50) {
      return Colors.green; // Very close - green
    } else if (distance <= 500) {
      return Colors.lightGreen; // Close - light green
    } else if (distance <= 1000) {
      return Colors.yellow; // Medium close - yellow
    } else if (distance <= 2500) {
      return Colors.orange; // Medium - orange
    } else if (distance <= 5000) {
      return Colors.deepOrange; // Far - deep orange
    } else if (distance <= 10000) {
      return Colors.red; // Very far - red
    } else if (distance <= 25000) {
      return Colors.purple; // Extremely far - purple
    } else {
      return Colors.indigo; // Maximum distance - indigo
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanController.dispose();
    _distanceController.dispose();
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
              if (_currentState == ScanningState.completed) ...[
                _buildFoundCardsSection(),
              ] else ...[
                const Spacer(),
                _buildCenterScanningIcon(),
                if (_statusText.isNotEmpty) _buildStatusText(),
                const Spacer(),
                _buildActionButton(),
                const SizedBox(height: 16),
              ],
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
            onPressed: _resetScanning,
          ),
        ],
      ),
    );
  }

  Widget _buildFoundCardsSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Found ${_foundCards.length} cards nearby',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).indicatorColor,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _foundCards.length,
              itemBuilder: (context, index) {
                return _buildCardItem(_foundCards[index]);
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
              onPressed: _resetScanning,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
              ),
              child: Text(
                'Scan Again',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Updated distance display text with better formatting
  String _getDistanceText(double distance) {
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)}m away';
    } else if (distance < 10000) {
      return '${(distance / 1000).toStringAsFixed(1)}km away';
    } else {
      return '${(distance / 1000).toStringAsFixed(0)}km away';
    }
  }

  // Updated card item with improved distance display
  Widget _buildCardItem(BusinessCard card) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NearbyScannedCardDetailsScreen(card: card),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: card.hasProfilePhoto
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image.network(
                            card.profilePhoto,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 25,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 25,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).indicatorColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        card.organization,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // Distance badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getDistanceColor(card.distance).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getDistanceColor(card.distance).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getDistanceText(card.distance),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getDistanceColor(card.distance),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDistanceBar(card.distance),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: _getDistanceColor(card.distance),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getDistanceRangeText(card.distance),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getDistanceColor(card.distance),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.navigation,
                      size: 14,
                      color: Theme.of(context).hintColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      card.direction,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).hintColor,
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

  String _getDistanceRangeText(double distance) {
    if (distance <= 50) {
      return 'Very Close';
    } else if (distance <= 500) {
      return 'Close';
    } else if (distance <= 1000) {
      return 'Nearby';
    } else if (distance <= 2500) {
      return 'Medium';
    } else if (distance <= 5000) {
      return 'Far';
    } else if (distance <= 10000) {
      return 'Very Far';
    } else if (distance <= 25000) {
      return 'Distant';
    } else {
      return 'Very Distant';
    }
  }

  List<Color> _getGradientColors(double distance) {
    Color mainColor = _getDistanceColor(distance);

    if (distance <= 50) {
      return [Colors.green.shade300, Colors.green, Colors.green.shade700];
    } else if (distance <= 500) {
      return [
        Colors.lightGreen.shade300,
        Colors.lightGreen,
        Colors.lightGreen.shade700
      ];
    } else if (distance <= 1000) {
      return [Colors.yellow.shade300, Colors.yellow, Colors.yellow.shade700];
    } else if (distance <= 2500) {
      return [Colors.orange.shade300, Colors.orange, Colors.orange.shade700];
    } else if (distance <= 5000) {
      return [
        Colors.deepOrange.shade300,
        Colors.deepOrange,
        Colors.deepOrange.shade700
      ];
    } else if (distance <= 10000) {
      return [Colors.red.shade300, Colors.red, Colors.red.shade700];
    } else if (distance <= 25000) {
      return [Colors.purple.shade300, Colors.purple, Colors.purple.shade700];
    } else {
      return [Colors.indigo.shade300, Colors.indigo, Colors.indigo.shade700];
    }
  }

  Widget _buildDistanceBar(double distance) {
    Color barColor = _getDistanceColor(distance);

    // Create gradient colors based on distance ranges
    List<Color> gradientColors = _getGradientColors(distance);

    return Container(
      height: 8, // Slightly increased height for better visibility
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _distanceController,
            builder: (context, child) {
              return Container(
                width: MediaQuery.of(context).size.width *
                    0.8 *
                    _distanceController
                        .value, // Fixed width (80% of screen width)
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: barColor.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              );
            },
          ),
          // Distance indicator dot
          AnimatedBuilder(
            animation: _distanceController,
            builder: (context, child) {
              return Positioned(
                right: 0,
                top: -2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: barColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: barColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusText() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Center(
        child: Text(
          _statusText,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).indicatorColor,
          ),
        ),
      ),
    );
  }

  Widget _buildCenterScanningIcon() {
    return Container(
      height: 300,
      alignment: Alignment.center,
      child: _currentState == ScanningState.idle
          ? _buildStaticIcon()
          : _buildAnimatedIcon(),
    );
  }

  Widget _buildStaticIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Static outer circle
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
              width: 1.5,
            ),
          ),
        ),
        // Static middle circle
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.4),
              width: 1.5,
            ),
          ),
        ),
        // Static inner circle
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.6),
              width: 2,
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
          ),
          child: const Icon(
            Icons.radar,
            color: Colors.white,
            size: 35,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedIcon() {
    return AnimatedBuilder(
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
              angle: _scanController.value * 6.28,
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
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
        onPressed: _currentState == ScanningState.idle ||
                _currentState == ScanningState.error
            ? _handleLocationPermissionAndScanning
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
        ),
        child: Text(
          _currentState == ScanningState.idle ||
                  _currentState == ScanningState.error
              ? Texts.startScanning
              : _statusText,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
