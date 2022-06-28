
import 'package:flutter/cupertino.dart';

import '../models/login_model.dart';
import '../models/user.dart';

class UserInfoProvider extends ChangeNotifier{
  User? _user;
  final AuthMethods _authMethods = AuthMethods();
  User get getUser => _user!;

  Future<void> refreshUser() async {
    User user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }

}