import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stalk_safe/singup.dart';
import 'package:stalk_safe/signin.dart';
import 'package:stalk_safe/home.dart';
import 'package:stalk_safe/profile.dart';
import 'package:stalk_safe/inbox.dart';
import 'package:stalk_safe/angela.dart';
import 'package:stalk_safe/image.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StalkSafe',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        primarySwatch: Colors.green,
      ),
      initialRoute: '/signin',
      routes: {
        '/signup': (context) => SignUp(),
        '/signin': (context) => SignIn(),
        '/home': (context) => Home(),
        '/profile': (context) => Profile(),
        '/inbox': (context) => Inbox(),
        '/angela': (context) => const Angela(),
        '/image': (context) => const ImageScreen(),
      },
    );
  }
}
