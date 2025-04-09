class CustomCard {
  final String? id;
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

  CustomCard({
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
      id: json['id'],
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
      // Fixed typo in the field name (was 'backgroundUrl')
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

  @override
  String toString() {
    return 'CustomCard(company: $company, email: $email)';
  }
}
