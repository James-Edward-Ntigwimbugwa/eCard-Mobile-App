import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationProvider with ChangeNotifier {
  double? _latitude;
  double? _longitude;
  String? _address;
  bool _isLocationSelected = false;

  // Getters
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  String? get address => _address;
  bool get isLocationSelected => _isLocationSelected;

  LatLng? get latLng {
    if (_latitude != null && _longitude != null) {
      return LatLng(_latitude!, _longitude!);
    }
    return null;
  }

  void updateLocation({
    required double latitude,
    required double longitude,
    String? address,
  }) {
    _latitude = latitude;
    _longitude = longitude;
    _address = address;
    _isLocationSelected = true;

    notifyListeners();

    debugPrint(
        'LocationProvider updated: lat=$latitude, lng=$longitude, address=$address');
  }

  void clearLocation() {
    _latitude = null;
    _longitude = null;
    _address = null;
    _isLocationSelected = false;

    notifyListeners();

    debugPrint('LocationProvider cleared');
  }

  void updateAddress(String address) {
    _address = address;
    notifyListeners();
  }

  bool get hasValidLocation {
    return _latitude != null &&
        _longitude != null &&
        _latitude!.abs() <= 90 &&
        _longitude!.abs() <= 180;
  }

  String get formattedLocation {
    if (hasValidLocation) {
      return '${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}';
    }
    return 'No location selected';
  }

  String get locationSummary {
    if (_address != null && _address!.isNotEmpty) {
      return _address!;
    } else if (hasValidLocation) {
      return formattedLocation;
    }
    return 'No location selected';
  }
}
