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
      json['userUuid'],
      json['title'] ?? '',
      id: json['id']?.toString(),
      uuid: json['uuid'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      createdBy: json['createdBy'],
      deleted: json['deleted'] ?? false,
      active: json['active'] ?? true,
      company: json['company'],
      organization: json['organization'],
      publishCard: json['publishCard'] ?? false,
      cardLogo: json['cardLogo'],
      profilePhoto: json['profilePhoto'],
      address: json['address'],
      cardDescription: json['cardDescription'],
      phoneNumber: json['phoneNumber'],
      department: json['department'],
      email: json['email'],
      linkedIn: json['linkedIn'],
      websiteUrl: json['websiteUrl'],
      backgroundColor: json['backgroundColor'],
      fontColor: json['fontColor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'title': title,
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

  CustomCard copyWith({
    String? id,
    String? title,
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
      title ?? this.title,
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
    return 'CustomCard(id: $id, title: $title, company: $company, organization: $organization, email: $email)';
  }
}
