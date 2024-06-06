

/*import 'package:amazon_cognito_identity_dart_2/cognito.dart';

class CognitoAuthService {
  final userPool = CognitoUserPool(
    'YOUR_USER_POOL_ID',
    'YOUR_CLIENT_ID',
  );

  Future<bool> signIn(String username, String password) async {
    final cognitoUser = CognitoUser(username, userPool);
    final authDetails = AuthenticationDetails(
      username: username,
      password: password,
    );

    try {
      await cognitoUser.authenticateUser(authDetails);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> signUp(String username, String password, int subscriptionType, List<String> timeFrames) async {
    final userAttributes = [
      AttributeArg(name: 'email', value: username),
      AttributeArg(name: 'custom:subscription_type', value: subscriptionType.toString()),
      AttributeArg(name: 'custom:time_frames', value: timeFrames.join(',')),
    ];

    try {
      await userPool.signUp(username, password, userAttributes: userAttributes);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}

 */
