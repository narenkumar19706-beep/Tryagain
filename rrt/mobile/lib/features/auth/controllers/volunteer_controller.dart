import 'package:flutter/material.dart';

import '../../../core/utils/validators.dart';
import '../models/volunteer.dart';

class VolunteerController extends ChangeNotifier {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? validateName(String? value) {
    if (!Validators.isNonEmpty(value)) {
      return 'Name is required.';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (!Validators.isValidEmail(value)) {
      return 'Enter a valid email.';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (!Validators.isValidPhone(value)) {
      return 'Enter a valid phone number.';
    }
    return null;
  }

  Future<Volunteer> submit() async {
    _isSubmitting = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 500));

    final volunteer = Volunteer(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
    );

    _isSubmitting = false;
    notifyListeners();

    return volunteer;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
