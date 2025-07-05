import 'dart:async';
import 'dart:convert';
import 'package:ecard_app/models/nearby_cards_spatial_data_model.dart';
import 'package:ecard_app/services/requests/device_proximity_requests.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;


class DeviceProximityService with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  int? _statusCode;
  List<BusinessCard> _nearbyDevices = [];
  NearbyCardsSpatialData? _lastResponse;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  int? get statusCode => _statusCode;
  List<BusinessCard> get nearbyDevices => _nearbyDevices;
  NearbyCardsSpatialData? get lastResponse => _lastResponse;
  bool get hasError => _errorMessage != null;
  bool get hasSuccess => _successMessage != null;

  // Clear messages
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  // Clear all data
  void clearData() {
    _nearbyDevices.clear();
    _lastResponse = null;
    _errorMessage = null;
    _successMessage = null;
    _statusCode = null;
    notifyListeners();
  }

  Future<NearbyCardsSpatialData?> getNearbyDevices({
    required Object jsonPayload,
  }) async {
    _setLoading(true);
    _clearMessages();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // Make the API request
      final http.Response response =
          await DeviceProximtyRequests.getNearbyProximalDevices(
        jsonBody: jsonPayload.toString(),
      );

      _statusCode = response.statusCode;

      // Handle different status codes
      switch (response.statusCode) {
        case 200:
          return _handleSuccessResponse(response);
        case 400:
          _setError("Bad request. Please check your input data.",
              response.statusCode);
          break;
        case 401:
          _setError("Unauthorized. Please check your authentication.",
              response.statusCode);
          break;
        case 403:
          _setError(
              "Forbidden. You don't have permission to access this resource.",
              response.statusCode);
          break;
        case 404:
          _setError("Service not found. Please try again later.",
              response.statusCode);
          break;
        case 408:
          _setError("Request timeout. Please check your internet connection.",
              response.statusCode);
          break;
        case 500:
          _setError("Internal server error. Please try again later.",
              response.statusCode);
          break;
        case 502:
          _setError("Bad gateway. Service is temporarily unavailable.",
              response.statusCode);
          break;
        case 503:
          _setError("Service unavailable. Please try again later.",
              response.statusCode);
          break;
        default:
          _setError(
              "Unexpected error occurred (${response.statusCode}). Please try again.",
              response.statusCode);
      }

      return null;
    } catch (e) {
      _setError(_getErrorMessage(e), _statusCode);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  NearbyCardsSpatialData? _handleSuccessResponse(http.Response response) {
    try {
      final Map<String, dynamic> jsonData = json.decode(response.body);

      // Parse the response using the model
      final NearbyCardsSpatialData apiResponse =
          NearbyCardsSpatialData.fromJson(jsonData);

      _lastResponse = apiResponse;
      _nearbyDevices = apiResponse.dataList;

      // Check if the API response indicates an error
      if (apiResponse.error) {
        _setError(
            apiResponse.message.isNotEmpty
                ? apiResponse.message
                : "An error occurred",
            response.statusCode);
        return null;
      }

      // Set success message based on results
      if (apiResponse.dataList.isEmpty) {
        _setSuccess("No nearby devices found at this location.");
      } else {
        _setSuccess(
            "Found ${apiResponse.dataList.length} nearby device${apiResponse.dataList.length > 1 ? 's' : ''}.");
      }

      return apiResponse;
    } catch (e) {
      _setError("Failed to parse response data: ${e.toString()}",
          response.statusCode);
      return null;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message, int? statusCode) {
    _errorMessage = message;
    _successMessage = null;
    _statusCode = statusCode;
    notifyListeners();
  }

  void _setSuccess(String message) {
    _successMessage = message;
    _errorMessage = null;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  String _getErrorMessage(dynamic error) {
    if (error is http.ClientException) {
      return "Network error. Please check your internet connection.";
    } else if (error is FormatException) {
      return "Invalid response format from server.";
    } else if (error is TimeoutException) {
      return "Request timed out. Please try again.";
    } else if (error.toString().contains('SocketException')) {
      return "No internet connection. Please check your network.";
    } else if (error.toString().contains('HandshakeException')) {
      return "SSL/TLS connection error. Please try again.";
    } else {
      return "An unexpected error occurred: ${error.toString()}";
    }
  }

  // Helper method to get nearby devices by distance
  List<BusinessCard> getDevicesByDistance({double? maxDistance}) {
    if (maxDistance == null) return _nearbyDevices;

    return _nearbyDevices
        .where((device) => device.distance <= maxDistance)
        .toList();
  }

  // Helper method to get devices sorted by distance
  List<BusinessCard> getDevicesSortedByDistance({bool ascending = true}) {
    final List<BusinessCard> sortedDevices = List.from(_nearbyDevices);
    sortedDevices.sort((a, b) {
      if (ascending) {
        return a.distance.compareTo(b.distance);
      } else {
        return b.distance.compareTo(a.distance);
      }
    });
    return sortedDevices;
  }

  // Helper method to get devices by organization
  List<BusinessCard> getDevicesByOrganization(String organization) {
    return _nearbyDevices
        .where((device) => device.organization
            .toLowerCase()
            .contains(organization.toLowerCase()))
        .toList();
  }

  // Helper method to refresh data
  Future<NearbyCardsSpatialData?> refreshNearbyDevices(
      {required Object jsonPayload}) async {
    clearData();
    return await getNearbyDevices(jsonPayload: jsonPayload);
  }
}
