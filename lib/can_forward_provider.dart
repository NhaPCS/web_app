import 'package:flutter/material.dart';

class CanForwardProvider extends ChangeNotifier {
  bool canForward = false;

  void updateCan(bool can) {
    canForward = can;
    notifyListeners();
  }
}
