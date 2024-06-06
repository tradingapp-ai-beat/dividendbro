class DummyAuthService {
  Future<bool> signIn(String username, String password) async {
    // Dummy logic: always return true
    await Future.delayed(Duration(seconds: 1));
    return true;
  }

  Future<bool> signUp(String username, String password, int subscriptionType, List<String> timeFrames) async {
    // Dummy logic: always return true and print subscription details
    await Future.delayed(Duration(seconds: 1));
    print("Subscription Type: $subscriptionType");
    print("Selected Time Frames: $timeFrames");
    return true;
  }
}
