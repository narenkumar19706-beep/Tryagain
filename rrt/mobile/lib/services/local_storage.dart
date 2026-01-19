import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _kLocationGranted = "locationGranted";

  static const _kName = "name";
  static const _kPhone = "phone";
  static const _kDistrict = "district";
  static const _kAreaName = "areaName";
  static const _kAddress = "address";

  static const _kLastSosId = "lastSosId";

  static Future<void> setLocationGranted(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kLocationGranted, v);
  }

  static Future<bool> isLocationGranted() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kLocationGranted) ?? false;
  }

  static Future<void> saveProfile({
    required String name,
    required String phone,
    required String district,
    required String areaName,
    required String address,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kName, name);
    await p.setString(_kPhone, phone);
    await p.setString(_kDistrict, district);
    await p.setString(_kAreaName, areaName);
    await p.setString(_kAddress, address);
  }

  static Future<bool> hasProfile() async {
    final p = await SharedPreferences.getInstance();
    final phone = p.getString(_kPhone);
    return phone != null && phone.trim().isNotEmpty;
  }

  static Future<String> getName() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kName) ?? "";
  }

  static Future<String> getPhone() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kPhone) ?? "";
  }

  static Future<String> getDistrict() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kDistrict) ?? "Bangalore";
  }

  static Future<String> getAreaName() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kAreaName) ?? "Indiranagar, Bangalore";
  }

  static Future<String> getAddress() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kAddress) ?? "12th Main, Indiranagar";
  }

  static Future<void> setLastSosId(String sosId) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kLastSosId, sosId);
  }

  static Future<String> getLastSosId() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kLastSosId) ?? "";
  }
}
