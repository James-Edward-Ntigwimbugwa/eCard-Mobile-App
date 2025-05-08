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
      id: json['id']?.toString(), // If present in other responses
      uuid: json['uuid'] ?? '',
      username: json['username'] ?? '',
      email: json['email'], // Not present in current response
      accessToken: json['token'] ?? '',
      refreshToken: json['refreshToken'] ?? '', // Map to 'token' field
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phone: json['phone'] ?? '',
      jobTitle: json['jobTitle'] ?? '',
      companyName: json['companyName'] ?? '',
    );
  }

  @override
  String toString() {
    return 'User{'
        'id: $id, '
        'uuid: $uuid'
        'username: $username, '
        'email: $email, '
        'accessToken: ${accessToken!.isNotEmpty ? "$accessToken" : "empty"}, '
        'firstName: $firstName, '
        'lastName: $lastName, '
        'phone: $phone, '
        'jobTitle: $jobTitle, '
        'companyName: $companyName}';
  }
}
