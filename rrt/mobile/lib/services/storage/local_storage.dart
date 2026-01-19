class LocalStorage {
  static final Map<String, Object?> _store = {};

  Future<void> setString(String key, String value) async {
    _store[key] = value;
  }

  String? getString(String key) {
    final value = _store[key];
    return value is String ? value : null;
  }

  Future<void> remove(String key) async {
    _store.remove(key);
  }
}
