
import 'package:ecard_app/modals/saved_card_response.dart';

class PersonSave {
  final String name;
  final String role;
  final String cardName;
  final String? imageUrl;
  final String? email;
  final String? phoneNumber;
  final String? company;

  PersonSave({
    required this.name,
    required this.role,
    required this.cardName,
    this.imageUrl,
    this.email,
    this.phoneNumber,
    this.company,
  });

  // Factory constructor to create PersonSave from SavedCardResponse
  factory PersonSave.fromSavedCardResponse(SavedCardResponse savedCard) {
    return PersonSave(
      name: savedCard.user.fullName.isNotEmpty
          ? savedCard.user.fullName
          : '${savedCard.user.firstName} ${savedCard.user.lastName}'.trim(),
      role: savedCard.user.jobTitle.isNotEmpty
          ? savedCard.user.jobTitle
          : 'Employee',
      cardName: savedCard.card.title.isNotEmpty
          ? savedCard.card.title
          : 'Business Card',
      imageUrl: savedCard.user.profilePhoto,
      email: savedCard.user.email,
      phoneNumber: savedCard.user.phoneNumber,
      company: savedCard.user.companyName,
    );
  }
}
