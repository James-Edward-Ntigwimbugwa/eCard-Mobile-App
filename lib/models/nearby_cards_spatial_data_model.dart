class NearbyCardsSpatialData {
  final bool error;
  final int code;
  final dynamic data;
  final List<BusinessCard> dataList;
  final String message;

  NearbyCardsSpatialData({
    required this.error,
    required this.code,
    this.data,
    required this.dataList,
    required this.message,
  });

  factory NearbyCardsSpatialData.fromJson(Map<String, dynamic> json) {
    return NearbyCardsSpatialData(
      error: json['error'] ?? false,
      code: json['code'] ?? 200,
      data: json['data'],
      dataList: (json['dataList'] as List<dynamic>?)
          ?.map((item) => BusinessCard.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'code': code,
      'data': data,
      'dataList': dataList.map((card) => card.toJson()).toList(),
      'message': message,
    };
  }
}

// Business Card Model
class BusinessCard {
  final String cardId;
  final String title;
  final String organization;
  final String email;
  final String phoneNumber;
  final String? cardLogo;
  final String profilePhoto;
  final double distance;
  final double latitude;
  final double longitude;
  final String direction;
  final double walkingDistance;
  final double walkingTime;
  final double drivingDistance;
  final double drivingTime;
  final String formattedWalkingTime;
  final String formattedDrivingTime;
  final String formattedWalkingDistance;
  final String formattedDrivingDistance;
  final String directionDescription;

  BusinessCard({
    required this.cardId,
    required this.title,
    required this.organization,
    required this.email,
    required this.phoneNumber,
    this.cardLogo,
    required this.profilePhoto,
    required this.distance,
    required this.latitude,
    required this.longitude,
    required this.direction,
    required this.walkingDistance,
    required this.walkingTime,
    required this.drivingDistance,
    required this.drivingTime,
    required this.formattedWalkingTime,
    required this.formattedDrivingTime,
    required this.formattedWalkingDistance,
    required this.formattedDrivingDistance,
    required this.directionDescription,
  });

  factory BusinessCard.fromJson(Map<String, dynamic> json) {
    return BusinessCard(
      cardId: json['cardId'] ?? '',
      title: json['title'] ?? '',
      organization: json['organization'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      cardLogo: json['cardLogo'],
      profilePhoto: json['profilePhoto'] ?? '',
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      direction: json['direction'] ?? '',
      walkingDistance: (json['walkingDistance'] as num?)?.toDouble() ?? 0.0,
      walkingTime: (json['walkingTime'] as num?)?.toDouble() ?? 0.0,
      drivingDistance: (json['drivingDistance'] as num?)?.toDouble() ?? 0.0,
      drivingTime: (json['drivingTime'] as num?)?.toDouble() ?? 0.0,
      formattedWalkingTime: json['formattedWalkingTime'] ?? '',
      formattedDrivingTime: json['formattedDrivingTime'] ?? '',
      formattedWalkingDistance: json['formattedWalkingDistance'] ?? '',
      formattedDrivingDistance: json['formattedDrivingDistance'] ?? '',
      directionDescription: json['directionDescription'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cardId': cardId,
      'title': title,
      'organization': organization,
      'email': email,
      'phoneNumber': phoneNumber,
      'cardLogo': cardLogo,
      'profilePhoto': profilePhoto,
      'distance': distance,
      'latitude': latitude,
      'longitude': longitude,
      'direction': direction,
      'walkingDistance': walkingDistance,
      'walkingTime': walkingTime,
      'drivingDistance': drivingDistance,
      'drivingTime': drivingTime,
      'formattedWalkingTime': formattedWalkingTime,
      'formattedDrivingTime': formattedDrivingTime,
      'formattedWalkingDistance': formattedWalkingDistance,
      'formattedDrivingDistance': formattedDrivingDistance,
      'directionDescription': directionDescription,
    };
  }

  // Helper method to check if the card has a logo
  bool get hasLogo => cardLogo != null && cardLogo!.isNotEmpty;

  // Helper method to check if the card has a profile photo
  bool get hasProfilePhoto => profilePhoto.isNotEmpty;

  // Helper method to get formatted location
  String get formattedLocation => '$latitude, $longitude';

  // Helper method to get distance info
  String get distanceInfo => 
      'Walking: $formattedWalkingDistance ($formattedWalkingTime) | '
      'Driving: $formattedDrivingDistance ($formattedDrivingTime)';

  @override
  String toString() {
    return 'BusinessCard(cardId: $cardId, title: $title, organization: $organization)';
  }
}
