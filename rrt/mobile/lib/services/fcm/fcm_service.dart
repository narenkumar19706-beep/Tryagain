class FcmService {
  Future<void> initialize() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  Future<void> refreshToken() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}
