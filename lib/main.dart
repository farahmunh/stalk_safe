import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stalk_safe/singup.dart';
import 'package:stalk_safe/signin.dart';
import 'package:stalk_safe/home.dart';
import 'package:stalk_safe/profile.dart';
import 'package:stalk_safe/inbox.dart';
import 'package:stalk_safe/angela.dart';
import 'package:stalk_safe/terms.dart';
import 'package:stalk_safe/privacy.dart';
import 'location_sharing_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Start the location-sharing service
  final locationService = LocationSharingService();
  locationService.startSharingLocation();

  runApp(MyApp(locationService: locationService));
}

class MyApp extends StatelessWidget {
  final LocationSharingService locationService;

  const MyApp({Key? key, required this.locationService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StalkSafe',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/signin',
      routes: {
        '/signup': (context) => SignUp(),
        '/signin': (context) => SignIn(),
        '/home': (context) => Home(),
        '/profile': (context) => Profile(),
        '/inbox': (context) => Inbox(),
        '/angela': (context) => Angela(),
        '/terms': (context) => const Terms(),
        '/privacy': (context) => const Privacy(),
      },
    );
  }
}
