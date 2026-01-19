import 'package:flutter/foundation.dart';

class ProfileController extends ChangeNotifier {
  String _name = 'Volunteer';
  String _email = 'volunteer@rrt.example';

  String get name => _name;
  String get email => _email;

  String get initials {
    final parts = _name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  void updateProfile({required String name, required String email}) {
    _name = name.trim();
    _email = email.trim();
    notifyListeners();
  }
}
