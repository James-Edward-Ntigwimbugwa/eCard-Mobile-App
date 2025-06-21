
class SavedCardResponse {
  final int id;
  final UserDetail user;
  final CardDetail card;
  final DateTime? savedDate;

  SavedCardResponse({
    required this.id,
    required this.user,
    required this.card,
    this.savedDate,
  });

  factory SavedCardResponse.fromJson(Map<String, dynamic> json) {
    return SavedCardResponse(
      id: json['id'],
      user: UserDetail.fromJson(json['user']),
      card: CardDetail.fromJson(json['card']),
      savedDate: json['savedDate'] != null
          ? DateTime.parse(json['savedDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'card': card.toJson(),
      'savedDate': savedDate?.toIso8601String(),
    };
  }
}

class UserDetail {
  final int id;
  final String uuid;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final bool deleted;
  final bool active;
  final String firstName;
  final String secondName;
  final String lastName;
  final String fullName;
  final String userName;
  final String companyName;
  final String email;
  final String phoneNumber;
  final String userType;
  final String oneTimePassword;
  final String? biography;
  final bool publishBio;
  final String? profilePhoto;
  final String jobTitle;
  final List<UserCard> userCards;
  final bool accountLocked;
  final bool accountExpired;
  final bool credentialsExpired;
  final bool enabled;
  final bool accountLockedByUser;

  UserDetail({
    required this.id,
    required this.uuid,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    required this.deleted,
    required this.active,
    required this.firstName,
    required this.secondName,
    required this.lastName,
    required this.fullName,
    required this.userName,
    required this.companyName,
    required this.email,
    required this.phoneNumber,
    required this.userType,
    required this.oneTimePassword,
    this.biography,
    required this.publishBio,
    this.profilePhoto,
    required this.jobTitle,
    required this.userCards,
    required this.accountLocked,
    required this.accountExpired,
    required this.credentialsExpired,
    required this.enabled,
    required this.accountLockedByUser,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      id: json['id'],
      uuid: json['uuid'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdBy: json['createdBy'],
      deleted: json['deleted'] ?? false,
      active: json['active'] ?? true,
      firstName: json['firstName'] ?? '',
      secondName: json['secondName'] ?? '',
      lastName: json['lastName'] ?? '',
      fullName: json['fullName'] ?? '',
      userName: json['userName'] ?? '',
      companyName: json['companyName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      userType: json['userType'] ?? '',
      oneTimePassword: json['oneTimePassword'] ?? '',
      biography: json['biography'],
      publishBio: json['publishBio'] ?? false,
      profilePhoto: json['profilePhoto'],
      jobTitle: json['jobTitle'] ?? '',
      userCards: (json['userCards'] as List?)
          ?.map((card) => UserCard.fromJson(card))
          .toList() ?? [],
      accountLocked: json['accountLocked'] ?? false,
      accountExpired: json['accountExpired'] ?? false,
      credentialsExpired: json['credentialsExpired'] ?? false,
      enabled: json['enabled'] ?? false,
      accountLockedByUser: json['accountLockedByUser'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'deleted': deleted,
      'active': active,
      'firstName': firstName,
      'secondName': secondName,
      'lastName': lastName,
      'fullName': fullName,
      'userName': userName,
      'companyName': companyName,
      'email': email,
      'phoneNumber': phoneNumber,
      'userType': userType,
      'oneTimePassword': oneTimePassword,
      'biography': biography,
      'publishBio': publishBio,
      'profilePhoto': profilePhoto,
      'jobTitle': jobTitle,
      'userCards': userCards.map((card) => card.toJson()).toList(),
      'accountLocked': accountLocked,
      'accountExpired': accountExpired,
      'credentialsExpired': credentialsExpired,
      'enabled': enabled,
      'accountLockedByUser': accountLockedByUser,
    };
  }
}

class CardDetail {
  final int id;
  final String uuid;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final bool deleted;
  final bool active;
  final String title;
  final String organization;
  final bool publishCard;
  final String? cardLogo;
  final String? profilePhoto;
  final String address;
  final String cardDescription;
  final String phoneNumber;
  final String? department;
  final String email;
  final String linkedIn;
  final String websiteUrl;
  final String? backgroundColor;
  final String fontColor;

  CardDetail({
    required this.id,
    required this.uuid,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    required this.deleted,
    required this.active,
    required this.title,
    required this.organization,
    required this.publishCard,
    this.cardLogo,
    this.profilePhoto,
    required this.address,
    required this.cardDescription,
    required this.phoneNumber,
    this.department,
    required this.email,
    required this.linkedIn,
    required this.websiteUrl,
    this.backgroundColor,
    required this.fontColor,
  });

  factory CardDetail.fromJson(Map<String, dynamic> json) {
    return CardDetail(
      id: json['id'],
      uuid: json['uuid'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdBy: json['createdBy'],
      deleted: json['deleted'] ?? false,
      active: json['active'] ?? true,
      title: json['title'] ?? '',
      organization: json['organization'] ?? '',
      publishCard: json['publishCard'] ?? false,
      cardLogo: json['cardLogo'],
      profilePhoto: json['profilePhoto'],
      address: json['address'] ?? '',
      cardDescription: json['cardDescription'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      department: json['department'],
      email: json['email'] ?? '',
      linkedIn: json['linkedIn'] ?? '',
      websiteUrl: json['websiteUrl'] ?? '',
      backgroundColor: json['backgroundColor'],
      fontColor: json['fontColor'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'deleted': deleted,
      'active': active,
      'title': title,
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
}

class UserCard {
  final int id;
  final String uuid;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final bool deleted;
  final bool active;
  final String title;
  final String organization;
  final bool publishCard;
  final String? cardLogo;
  final String? profilePhoto;
  final String address;
  final String cardDescription;
  final String phoneNumber;
  final String? department;
  final String email;
  final String linkedIn;
  final String websiteUrl;
  final String? backgroundColor;
  final String fontColor;

  UserCard({
    required this.id,
    required this.uuid,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    required this.deleted,
    required this.active,
    required this.title,
    required this.organization,
    required this.publishCard,
    this.cardLogo,
    this.profilePhoto,
    required this.address,
    required this.cardDescription,
    required this.phoneNumber,
    this.department,
    required this.email,
    required this.linkedIn,
    required this.websiteUrl,
    this.backgroundColor,
    required this.fontColor,
  });

  factory UserCard.fromJson(Map<String, dynamic> json) {
    return UserCard(
      id: json['id'],
      uuid: json['uuid'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      createdBy: json['createdBy'],
      deleted: json['deleted'] ?? false,
      active: json['active'] ?? true,
      title: json['title'] ?? '',
      organization: json['organization'] ?? '',
      publishCard: json['publishCard'] ?? false,
      cardLogo: json['cardLogo'],
      profilePhoto: json['profilePhoto'],
      address: json['address'] ?? '',
      cardDescription: json['cardDescription'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      department: json['department'],
      email: json['email'] ?? '',
      linkedIn: json['linkedIn'] ?? '',
      websiteUrl: json['websiteUrl'] ?? '',
      backgroundColor: json['backgroundColor'],
      fontColor: json['fontColor'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'deleted': deleted,
      'active': active,
      'title': title,
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
}