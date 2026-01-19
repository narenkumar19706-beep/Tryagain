import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/fcm_service.dart';
import '../services/local_storage.dart';

class ProfileOnboardingScreen extends StatefulWidget {
  final VoidCallback onContinue;
  const ProfileOnboardingScreen({super.key, required this.onContinue});

  @override
  State<ProfileOnboardingScreen> createState() =>
      _ProfileOnboardingScreenState();
}

class _ProfileOnboardingScreenState extends State<ProfileOnboardingScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _saving = false;
  String? _error;

  String _digitsOnly(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');

  Future<void> _save() async {
    setState(() {
      _error = null;
      _saving = true;
    });

    final name = _nameCtrl.text.trim();
    final phoneRaw = _digitsOnly(_phoneCtrl.text.trim());

    if (name.isEmpty) {
      setState(() {
        _saving = false;
        _error = "Enter your name";
      });
      return;
    }

    if (phoneRaw.length != 10) {
      setState(() {
        _saving = false;
        _error = "Enter valid 10 digit mobile number";
      });
      return;
    }

    const district = "East Bangalore";
    const areaName = "Indiranagar, Bangalore";
    const address = "12th Main, Indiranagar";

    try {
      final token = await FcmService.token();
      if (token == null) throw Exception("FCM token not available");

      await LocalStorage.saveProfile(
        name: name,
        phone: phoneRaw,
        district: district,
        areaName: areaName,
        address: address,
      );

      await ApiService.register(
        name: name,
        phoneNumber: phoneRaw,
        district: district,
        fcmToken: token,
        address: address,
      );

      widget.onContinue();
    } catch (e) {
      setState(() {
        _saving = false;
        _error = "Failed to save. Check backend + internet.";
      });
      return;
    }

    setState(() => _saving = false);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12, width: 1),
                  color: Colors.white,
                ),
                child: const Center(
                  child: Icon(Icons.pets, size: 22, color: Colors.black),
                ),
              ),
              const SizedBox(height: 26),
              const Text(
                "Rapid",
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.2,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Response Team",
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.0,
                  height: 1.0,
                  color: Color(0xFF9AA0A6),
                ),
              ),
              const SizedBox(height: 36),
              const Text(
                "Your Profile",
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                "NAME",
                style: TextStyle(
                  fontSize: 14,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFB6BCC6),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  hintText: "Enter Name",
                  hintStyle: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1.2),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                ),
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 30),
              const Text(
                "MOBILE NUMBER",
                style: TextStyle(
                  fontSize: 14,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFB6BCC6),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: "+91 00000 00000",
                  hintStyle: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1.2),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                ),
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 18),
              const Text(
                "MANDATORY FOR ALERTS.\nYOUR PHONE NUMBER IS EXPOSED ONLY WHILE AN SOS\nALERT IS ACTIVE. PRIVACY BY DESIGN.",
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 2.0,
                  height: 1.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFB6BCC6),
                ),
              ),
              const Spacer(),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFE11B22),
                    ),
                  ),
                ),
              Container(
                width: w,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: InkWell(
                  onTap: _saving ? null : _save,
                  child: Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            _saving ? "SAVING..." : "SAVE & PROCEED",
                            style: const TextStyle(
                              fontSize: 16,
                              letterSpacing: 4,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: Colors.white24,
                      ),
                      const SizedBox(
                        width: 70,
                        child: Center(
                          child: Icon(Icons.arrow_forward_rounded,
                              size: 28, color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                "SECURE  ACCESS   •   PRIVACY  ENSURED",
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 2.2,
                  fontWeight: FontWeight.w700,
                  color: Colors.black.withOpacity(0.22),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
