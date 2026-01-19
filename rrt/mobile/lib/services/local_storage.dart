import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _kLocationGranted = 'locationGranted';
  static const _kName = 'name';
  static const _kPhone = 'phone';
  static const _kDistrict = 'district';
  static const _kAreaName = 'areaName';

  static Future<void> setLocationGranted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLocationGranted, value);
  }

  static Future<bool> isLocationGranted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kLocationGranted) ?? false;
  }

  static Future<void> saveProfile({
    required String name,
    required String phone,
    required String district,
    required String areaName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kName, name);
    await prefs.setString(_kPhone, phone);
    await prefs.setString(_kDistrict, district);
    await prefs.setString(_kAreaName, areaName);
  }

  static Future<bool> hasProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString(_kPhone);
    return phone != null && phone.trim().isNotEmpty;
  }

  static Future<String> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kName) ?? '';
  }

  static Future<String> getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kPhone) ?? '';
  }

  static Future<String> getDistrict() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kDistrict) ?? 'Bangalore';
  }

  static Future<String> getAreaName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kAreaName) ?? 'Indiranagar, Bangalore';
  }
}
