import 'package:ecard_app/components/custom_widgets.dart';
import 'package:ecard_app/providers/location_provider.dart';
import 'package:ecard_app/services/device_proximity_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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


void _handleLocationPermissionAndScanning() async {
  try {
    var status = await Permission.location.status;
    
    // Request permission if not granted
    if (!status.isGranted) {
      status = await Permission.location.request();
    }
    
    if (status.isGranted) {
      // Background location fetch
      await _fetchLocationAndStartScanning();
    } else {
      _showPermissionDialog();
    }
  } catch (e) {
    var status = await Permission.location.status;
    if (status.isDenied || status.isRestricted) {
      _showPermissionDialog();
    }
  }
}

Future<void> _fetchLocationAndStartScanning() async {
  try {
    // Get current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Get address from coordinates
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
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
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

    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    locationProvider.updateLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      address: address,
    );

    final deviceProximityService = Provider.of<DeviceProximityService>(context, listen: false);
    
    final prefs = await SharedPreferences.getInstance();
    final String? userUuid = prefs.getString('userUuid');
    
    await deviceProximityService.getNearbyDevices(
      userUuid: userUuid,
      latitude: position.latitude,
      longitude: position.longitude,
    );
    
    // Handle the response
    if (deviceProximityService.hasSuccess) {
      // Show success message or update UI
      print("Scanning completed: ${deviceProximityService.successMessage}");
    } else if (deviceProximityService.hasError) {
      // Show error message
      print("Scanning failed: ${deviceProximityService.errorMessage}");
    }
    
  } catch (e) {
    print("Error fetching location: $e");
    // Handle location fetch error
  }
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
        onPressed: _handleLocationPermissionAndScanning,
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
}
