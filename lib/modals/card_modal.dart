class CustomCard {
  final String? id;
  final String? title;
  final String? uuid;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final bool deleted;
  final bool active;
  final String? company;
  final String? organization;
  final bool publishCard;
  final String? cardLogo;
  final String? profilePhoto;
  final String? address;
  final String? cardDescription;
  final String? phoneNumber;
  final String? department;
  final String? email;
  final String? linkedIn;
  final String? websiteUrl;
  final String? backgroundColor;
  final String? fontColor;
  final String? userUuid;

  CustomCard(
    this.userUuid,
    this.title, {
    this.id,
    this.uuid,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.deleted = false,
    this.active = true,
    this.company,
    this.organization,
    this.publishCard = false,
    this.cardLogo,
    this.profilePhoto,
    this.address,
    this.cardDescription,
    this.phoneNumber,
    this.department,
    this.email,
    this.linkedIn,
    this.websiteUrl,
    this.backgroundColor,
    this.fontColor,
  });

  factory CustomCard.fromJson(Map<String, dynamic> json) {
    return CustomCard(
      json['userUuid'] ??
          '', // Provide a default or extract 'userUuid' from JSON
      json['title'] ?? '', // Provide a default or extract 'title' from JSON
      id: json['id']?.toString(),
      uuid: json['uuid'] ?? '',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is String
              ? DateTime.parse(json['createdAt'])
              : null)
          : null,
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] is String
              ? DateTime.parse(json['updatedAt'])
              : null)
          : null,
      createdBy: json['createdBy'],
      deleted: json['deleted'] == 1 || json['deleted'] == true,
      active: json['active'] == null ||
          json['active'] == 1 ||
          json['active'] == true,
      company: json['company'] ?? '',
      organization: json['organization'],
      publishCard: json['publishCard'] == 1 || json['publishCard'] == true,
      cardLogo: json['cardLogo'] ?? '',
      profilePhoto: json['profilePhoto'] ?? '',
      address: json['address'] ?? '',
      cardDescription: json['cardDescription'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      department: json['department'] ?? '',
      email: json['email'] ?? '',
      linkedIn: json['linkedIn'] ?? '',
      websiteUrl: json['websiteUrl'] ?? '',
      backgroundColor: json['backgroundColor'] ?? json['backgroundUrl'],
      fontColor: json['fontColor'],
    );
  }

  // Convert card to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'createdBy': createdBy,
      'deleted': deleted,
      'active': active,
      'company': company,
      'organization': organization,
      'publishCard': publishCard,
      'cardLogo': cardLogo,
      'profilePhoto': profilePhoto,
      'address': address,
      'cardDescription': cardDescription,
      'phoneNumber': phoneNumber,
      'department': department,
      'email': email,
      'linkedIn': linkedIn,
      'websiteUrl': websiteUrl,
      'backgroundColor': backgroundColor,
      'fontColor': fontColor,
    };
  }

  // Create a copy of the card with updated fields
  CustomCard copyWith({
    String? id,
    String? uuid,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    bool? deleted,
    bool? active,
    String? company,
    String? organization,
    bool? publishCard,
    String? cardLogo,
    String? profilePhoto,
    String? address,
    String? cardDescription,
    String? phoneNumber,
    String? department,
    String? email,
    String? linkedIn,
    String? websiteUrl,
    String? backgroundColor,
    String? fontColor,
  }) {
    return CustomCard(
      userUuid,
      title,
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      deleted: deleted ?? this.deleted,
      active: active ?? this.active,
      company: company ?? this.company,
      organization: organization ?? this.organization,
      publishCard: publishCard ?? this.publishCard,
      cardLogo: cardLogo ?? this.cardLogo,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      address: address ?? this.address,
      cardDescription: cardDescription ?? this.cardDescription,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      department: department ?? this.department,
      email: email ?? this.email,
      linkedIn: linkedIn ?? this.linkedIn,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      fontColor: fontColor ?? this.fontColor,
    );
  }

  @override
  String toString() {
    return 'CustomCard(company: $company, email: $email)';
  }
}
