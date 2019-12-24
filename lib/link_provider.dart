import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LinkProvider extends ChangeNotifier {
  String currentLink = "";

  void updateLink(String link) async {
    currentLink = link;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('link', currentLink);
    notifyListeners();
  }

  void getLink() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = prefs.getString('link');
    if (url != null) {
      currentLink = url;
      notifyListeners();
    }
  }
}
