import 'package:flutter/material.dart';

class MenuProvider with ChangeNotifier {
  bool _isMainDataMenuOpen = false;
  bool _isLandMenuOpen = false;

  bool get isMainDataMenuOpen => _isMainDataMenuOpen;
  bool get isLandMenuOpen => _isLandMenuOpen;

  void toggleMainDataMenu(bool isOpen) {
    _isMainDataMenuOpen = isOpen;
    notifyListeners();
  }

  void toggleLandMenu(bool isOpen) {
    _isLandMenuOpen = isOpen;
    notifyListeners();
  }
}