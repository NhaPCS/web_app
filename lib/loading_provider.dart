import 'package:flutter/material.dart';

class LoadingProvider extends ChangeNotifier {
  bool loading = false;

  void updateLoading(bool load) {
    loading = load;
    notifyListeners();
  }
}
