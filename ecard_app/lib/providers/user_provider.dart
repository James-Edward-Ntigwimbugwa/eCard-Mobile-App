import 'package:ecard_app/modals/user_modal.dart';
import 'package:flutter/cupertino.dart';

class UserProvider with ChangeNotifier {
  User _user = User();

  User get user => _user;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void clearSession(){
    _user = User();
    notifyListeners();
  }

}
