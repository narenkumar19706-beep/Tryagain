import 'package:flutter/material.dart';

import '../../../core/widgets/primary_button.dart';
import '../controllers/volunteer_controller.dart';

class VolunteerRegisterScreen extends StatefulWidget {
  const VolunteerRegisterScreen({super.key});

  @override
  State<VolunteerRegisterScreen> createState() =>
      _VolunteerRegisterScreenState();
}

class _VolunteerRegisterScreenState extends State<VolunteerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late final VolunteerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VolunteerController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final volunteer = await _controller.submit();
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Welcome, ${volunteer.name}!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer Registration'),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _controller.nameController,
                    decoration: const InputDecoration(labelText: 'Full name'),
                    validator: _controller.validateName,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _controller.emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: _controller.validateEmail,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _controller.phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    validator: _controller.validatePhone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Register',
                    isLoading: _controller.isSubmitting,
                    onPressed: _controller.isSubmitting ? null : _submit,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
