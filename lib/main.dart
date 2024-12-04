import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trading_advice_app_v2/screens/welcome_screen.dart';
import 'provider/user_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/image_selection_screen.dart';
import 'screens/subscription_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
