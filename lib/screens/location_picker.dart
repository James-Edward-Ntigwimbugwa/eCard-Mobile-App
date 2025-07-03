import 'dart:async';
import 'dart:ui';
import 'package:ecard_app/components/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';

import '../providers/location_provider.dart';

class GoogleMapLocationPicker extends StatefulWidget {
  const GoogleMapLocationPicker({super.key});

  @override
  State<StatefulWidget> createState() => GoogleMapLocationPickerState();
}

class GoogleMapLocationPickerState extends State<GoogleMapLocationPicker> {
  final Completer<GoogleMapController> _controller = Completer();
  static const LatLng _initialCenter = LatLng(-6.804464, 39.213836);

  LatLng? _currentPosition;
  LatLng _selectedPosition = _initialCenter;
  bool _isLoading = true;
  Set<Marker> _markers = {};
  String? _selectedAddress;
  bool _isFetchingAddress = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _updateSelectedPosition(_initialCenter);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _updateSelectedPosition(_initialCenter);
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final LatLng latLng = LatLng(position.latitude, position.longitude);
      _currentPosition = latLng;
      _updateSelectedPosition(latLng);
      _animateToPosition(latLng);
    } catch (e) {
      _updateSelectedPosition(_initialCenter);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _updateSelectedPosition(LatLng position) {
    setState(() {
      _selectedPosition = position;
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          draggable: true,
          onDragEnd: (newPosition) {
            _updateSelectedPosition(newPosition);
          },
        ),
      };
    });
    _fetchAddress(position);
  }

  Future<void> _fetchAddress(LatLng position) async {
    setState(() {
      _isFetchingAddress = true;
      _selectedAddress = null;
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        // Build a more comprehensive address
        List<String> addressParts = [];

        // Add subLocality (like Mabibo)
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }

        // Add locality (like Dar es Salaam)
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }

        // Add administrativeArea (like Dar es Salaam Region)
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }

        // Add country
        if (place.country != null && place.country!.isNotEmpty) {
          addressParts.add(place.country!);
        }

        // If we still don't have subLocality, try thoroughfare or name
        if (addressParts.isEmpty ||
            (place.subLocality == null || place.subLocality!.isEmpty)) {
          if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
            addressParts.insert(0, place.thoroughfare!);
          } else if (place.name != null && place.name!.isNotEmpty) {
            addressParts.insert(0, place.name!);
          }
        }

        String address = addressParts.join(', ');
        setState(() {
          _selectedAddress = address.isNotEmpty ? address : "Address not found";
        });
      } else {
        setState(() {
          _selectedAddress = "Address not found";
        });
      }
    } catch (e) {
      setState(() {
        _selectedAddress = "Error fetching address";
      });
    } finally {
      setState(() {
        _isFetchingAddress = false;
      });
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        LatLng newPosition = LatLng(location.latitude, location.longitude);
        _updateSelectedPosition(newPosition);
        _animateToPosition(newPosition);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location not found")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error searching location")),
      );
    }
  }

  Future<void> _animateToPosition(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: position,
        zoom: 15.0,
      ),
    ));
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void _onMapTapped(LatLng position) {
    _updateSelectedPosition(position);
  }

  void _confirmLocation() {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);

    locationProvider.updateLocation(
      latitude: _selectedPosition.latitude,
      longitude: _selectedPosition.longitude,
      address: _selectedAddress,
    );

    // Return the selected position (optional, for backward compatibility)
    Navigator.pop(context, _selectedPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).highlightColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: AppBar(
          backgroundColor: Theme.of(context).highlightColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Column(
              children: [
                // Title Row
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: Theme.of(context).indicatorColor,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          "Pick Location",
                          style: TextStyle(
                            color: Theme.of(context).indicatorColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48), // Balance the back button
                    ],
                  ),
                ),
                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: TextField(
                                controller: _searchController,
                                style: TextStyle(
                                    color: Theme.of(context).indicatorColor),
                                decoration: InputDecoration(
                                  hintText: "Search for a location...",
                                  hintStyle: TextStyle(
                                    color: Theme.of(context)
                                        .indicatorColor
                                        .withOpacity(0.7),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.7),
                                      width: 1.4,
                                    ),
                                  ),
                                ),
                                textInputAction: TextInputAction.search,
                                onSubmitted: (value) {
                                  _searchLocation(value);
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          _searchLocation(_searchController.text);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              // Add border
                              foregroundDecoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.7),
                                  width: 1.4,
                                ),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Icon(
                                Icons.search,
                                color: Theme.of(context).indicatorColor,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _initialCenter,
              zoom: 14.0,
            ),
            markers: _markers,
            onTap: _onMapTapped,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          Positioned(
            bottom: 80,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              color: Theme.of(context).secondaryHeaderColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        NormalHeaderWidget(
                          text: "Selected Location",
                          color: Theme.of(context).indicatorColor,
                          size: '16.0',
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_isFetchingAddress)
                      const Center(child: CircularProgressIndicator())
                    else if (_selectedAddress != null)
                      Text(
                        _selectedAddress!,
                        style: TextStyle(
                          color: Theme.of(context).indicatorColor,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      Text(
                        "Select a location",
                        style: TextStyle(
                          color:
                              Theme.of(context).indicatorColor.withOpacity(0.7),
                        ),
                      ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _confirmLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("Confirm Location"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "btn_current_location",
            onPressed: () {
              if (_currentPosition != null) {
                _updateSelectedPosition(_currentPosition!);
                _animateToPosition(_currentPosition!);
              } else {
                _getCurrentLocation();
              }
            },
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "btn_update_location",
            onPressed: _confirmLocation,
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.check),
          ),
        ],
      ),
    );
  }
}
