import 'dart:async';
import 'package:ecard_app/components/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart'; // Added for geocoding and reverse geocoding

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
  String? _selectedAddress; // To store the fetched address
  bool _isFetchingAddress = false; // To track address fetching state
  final TextEditingController _searchController =
      TextEditingController(); // For search input

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose(); // Clean up the controller
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
    _fetchAddress(position); // Fetch the address for the selected position
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
        String address = [place.street, place.locality, place.country]
            .where((e) => e != null && e.isNotEmpty)
            .join(', ');
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
    Navigator.pop(context, _selectedPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).highlightColor,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.location_on, color: Theme.of(context).indicatorColor),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search for a location",
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                      color: Theme.of(context).indicatorColor.withOpacity(0.5)),
                ),
                style: TextStyle(color: Theme.of(context).indicatorColor),
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  _searchLocation(value);
                },
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).highlightColor,
        elevation: 0,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).indicatorColor,
          ),
          onPressed: () => Navigator.pop(context),
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
