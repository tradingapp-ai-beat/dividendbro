import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:trading_advice_app_v2/screens/welcome_screen.dart';
import 'provider/user_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/image_selection_screen.dart';
import 'screens/subscription_screen.dart';
import 'firebase_options.dart'; // Make sure this file is generated and included in your project
import 'services/email_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");

  print('API Key: ${dotenv.env['FIREBASE_API_KEY']}');
  print('API Key: ${dotenv.env['FIREBASE_API_KEY_ANDROID']}');
  print('App ID: ${dotenv.env['FIREBASE_APP_ID']}');
  print('Messaging Sender ID: ${dotenv.env['FIREBASE_MESSAGING_SENDER_ID']}');
  print('Project ID: ${dotenv.env['FIREBASE_PROJECT_ID']}');
  print('Auth Domain: ${dotenv.env['FIREBASE_AUTH_DOMAIN']}');
  print('Storage Bucket: ${dotenv.env['FIREBASE_STORAGE_BUCKET']}');
  print('Measurement ID: ${dotenv.env['FIREBASE_MEASUREMENT_ID']}');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //EmailService.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'dividendBeat',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: WelcomeScreen(),
      ),
    );
  }
}

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    if (userProvider.user.email.isEmpty) {
      return SignInScreen();
    } else {
      return userProvider.hasActiveSubscription || userProvider.isTrialPeriodActive
          ? ImageSelectionScreen(
        subscribedTimeFrames: userProvider.user.timeFrames,
        name: userProvider.user.name,
      )
          : SubscriptionScreen();
    }
  }
}
