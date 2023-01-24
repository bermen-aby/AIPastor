import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';

import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';

import 'models/chat_model.dart';
import '/pages/chat_page/chat_page.dart';
import '/provider/loader_provider.dart';
import 'constants.dart';
import 'variables.dart';
import 'theme.dart';

/*const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();*/

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
    } else {
      rethrow;
    }
  } catch (e) {
    rethrow;
  }
  if (kDebugMode) {
    print('A bg msg: ${message.messageId}');
  }
}

// ---------------------------------------------------------
// MAIN

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const MyApp(),
  );
}

// ---------------------------------------------------------
// APP

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LoaderProvider(),
          child: const ChatPage(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightThemeData(context),
        darkTheme: darkThemeData(context),
        title: 'Login Page',
        home: //const ChatPage(),
            AnimatedSplashScreen(
                backgroundColor: Theme.of(context).backgroundColor,
                splashIconSize: 512,
                splash: Image.asset(
                  "assets/images/splashscreen.png",
                  height: double.infinity,
                ),
                nextScreen: const ChatPage()),
      ),
    );
    // return MaterialApp(
    //   title: 'Login Page',
    //   home: LoginPage(),
    // );
  }
}
