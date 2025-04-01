import 'package:ecard_app/modals/card_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CardPreferences {
  static Future<bool> saveCard(CustomCard card) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setInt('card-id', card.id as int);
    prefs.setString('card-uuid', card.uuid.toString());
    prefs.setString('card-createdAt', card.createdAt!.timeZoneName);
    prefs.setString('card-updatedAt', card.updatedAt!.timeZoneName);
    prefs.setBool('card-deleted', card.deleted!);
    prefs.setBool('card-active', card.active!);
    prefs.setString('card-company', card.company.toString());
    prefs.setString('card-organization', card.organization.toString());
    prefs.setString('card-profilePhoto', card.profilePhoto.toString());
    prefs.setString('card-address', card.address.toString());
    prefs.setString('card-PhoneNumber', card.phoneNumber.toString());
    prefs.setString('card-email', card.email.toString());

    return prefs.commit();
  }
}
