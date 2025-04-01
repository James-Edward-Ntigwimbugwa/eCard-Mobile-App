class CustomCard {
  final String? id;
  final String? uuid;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final bool? deleted;
  final bool? active;
  final String? company;
  final String? organization;
  final bool? publishCard;
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

  CustomCard(
      {this.id,
      this.uuid,
      this.createdAt,
      this.updatedAt,
      this.createdBy,
      this.deleted,
      this.active,
      this.company,
      this.organization,
      this.publishCard,
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
      this.fontColor});

  factory CustomCard.fromJson(Map<String, dynamic> json) {
    return CustomCard(
        id: json['id'],
        uuid: json['uuid'],
        createdAt: json['createdAt'],
        updatedAt: json['updatedAt'],
        createdBy: json['createdBy'],
        deleted: json['deleted'],
        active: json['active'],
        company: json['company'],
        organization: json['organization'],
        publishCard: json['publishCard'],
        cardLogo: json['cardLogo'],
        profilePhoto: json['profilePhoto'],
        address: json['address'],
        cardDescription: json['cardDescription'],
        phoneNumber: json['phoneNumber'],
        department: json['department'],
        email: json['email'],
        linkedIn: json['linkedIn'],
        websiteUrl: json['websiteUrl'],
        backgroundColor: json['backgroundUrl'],
        fontColor: json['fontColor']);
  }
}
