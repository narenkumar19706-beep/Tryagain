import 'dart:collection';

class SosAlert {
  final String sosId;
  final String district;
  final String phoneNumber;
  final String raisedByName;
  final String address;
  final double? lat;
  final double? lng;
  final DateTime startedAt;
  bool active;

  final List<SosUpdate> updates;

  SosAlert({
    required this.sosId,
    required this.district,
    required this.phoneNumber,
    required this.raisedByName,
    required this.address,
    required this.lat,
    required this.lng,
    required this.startedAt,
    this.active = true,
    List<SosUpdate>? updates,
  }) : updates = updates ?? [];
}

class SosUpdate {
  final String message;
  final DateTime at;

  SosUpdate({required this.message, required this.at});
}

class AlertStore {
  static final List<SosAlert> _alerts = [];

  static UnmodifiableListView<SosAlert> get alerts =>
      UnmodifiableListView(_alerts);

  static SosAlert? findById(String sosId) {
    for (final a in _alerts) {
      if (a.sosId == sosId) return a;
    }
    return null;
  }

  static void upsertStart({
    required String sosId,
    required String district,
    required String phoneNumber,
    required String name,
    required String address,
    required double? lat,
    required double? lng,
    required DateTime startedAt,
  }) {
    final existing = findById(sosId);
    if (existing != null) {
      existing.active = true;
      return;
    }

    _alerts.insert(
      0,
      SosAlert(
        sosId: sosId,
        district: district,
        phoneNumber: phoneNumber,
        raisedByName: name.isEmpty ? "Unknown" : name,
        address: address.isEmpty ? "Location not available" : address,
        lat: lat,
        lng: lng,
        startedAt: startedAt,
        active: true,
      ),
    );
  }

  static void addUpdate({
    required String sosId,
    required String message,
    required DateTime at,
  }) {
    final existing = findById(sosId);
    if (existing == null) return;
    existing.updates.insert(0, SosUpdate(message: message, at: at));
  }

  static void markStopped(String sosId) {
    final existing = findById(sosId);
    if (existing == null) return;
    existing.active = false;
  }
}
