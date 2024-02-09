import 'package:flutter/material.dart';

class MyProvider extends ChangeNotifier {
   int _activeField = 0;
   bool _isExists = false;
   bool _emailValid = true;
   bool _isPwdValid = true;
   bool _isPwdMatches = true;
   bool _isUserValid = true;
   bool _fetchingCompleted = false;
   bool _express = false;
  get fetchingCompleted => _fetchingCompleted;
  get activeField => _activeField;
  get isExists => _isExists;
  get showExpress => _express;

  get isUsernameValid => _isUserValid;
  get isEmailValid => _emailValid;
  get isPwdValid => _isPwdValid;
  get isPwdMatches => _isPwdMatches;
  void setExpress(){_express = !_express;notifyListeners();}
   void changeActiveField(int f){_activeField = f;
     notifyListeners();}
  void setExistance(bool v){_isExists=v;notifyListeners();}
  void validateUsername(bool v){_isUserValid=v;notifyListeners();}
  void validatePwd(bool v){_isPwdValid=v;notifyListeners();}
  void validateConfirmation(bool v){_isPwdMatches=v;notifyListeners();}
  void validateEmail(bool v) {_emailValid = v;notifyListeners();}
  void reset(){
     _isUserValid = true;
     _isPwdValid = true;
  }
  void completeFetching(){
     _fetchingCompleted = true;
     notifyListeners();
  }
}
