import 'package:flutter/material.dart';

class SosController extends ChangeNotifier {
  bool _isSending = false;
  bool get isSending => _isSending;

  Future<void> sendSos() async {
    if (_isSending) {
      return;
    }
    _isSending = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(seconds: 1));

    _isSending = false;
    notifyListeners();
  }
}
