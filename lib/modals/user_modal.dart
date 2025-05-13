// Fixed User model with proper toString and non-null field handling
class User {
  final String? id;
  final String? uuid;
  final String? username;
  final String? email;
  final String? accessToken;
  final String? firstName;
  final String? userType;
  final String? lastName;
  final String? phone;
  final String? refreshToken;
  final String? jobTitle;
  final String? companyName;

  User({
    this.id,
    this.uuid,
    this.username,
    this.email,
    this.accessToken,
    this.firstName,
    this.userType,
    this.refreshToken,
    this.lastName,
    this.phone,
    this.jobTitle,
    this.companyName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      uuid: json['uuid'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '', // Ensure email is never null
      accessToken: json['token'] ?? json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phone: json['phone'] ?? '',
      userType: json['type'] ?? json['userType'] ?? '',
      jobTitle: json['jobTitle'] ?? '',
      companyName: json['companyName'] ?? '',
    );
  }

  // Convert User object to JSON for debugging and storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'username': username,
      'email': email,
      'accessToken': accessToken != null && accessToken!.isNotEmpty ? 'Token exists' : 'No token',
      'refreshToken': refreshToken != null && refreshToken!.isNotEmpty ? 'Token exists' : 'No token',
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'userType': userType,
      'jobTitle': jobTitle,
      'companyName': companyName,
    };
  }

  @override
  String toString() {
    return 'User{'
        'id: $id, '
        'uuid: $uuid, '
        'username: $username, '
        'email: $email, '
        'accessToken: ${accessToken != null && accessToken!.isNotEmpty ? "Token exists" : "No token"}, '
        'refreshToken: ${refreshToken != null && refreshToken!.isNotEmpty ? "Token exists" : "No token"}, '
        'firstName: $firstName, '
        'lastName: $lastName, '
        'phone: $phone, '
        'userType: $userType, '
        'jobTitle: $jobTitle, '
        'companyName: $companyName}';
  }
}