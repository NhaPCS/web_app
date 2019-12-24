import 'package:flutter/material.dart';

class CanBackProvider extends ChangeNotifier {
  bool canBack = false;

  void updateCan(bool can) {
    canBack = can;
    notifyListeners();
  }
}
