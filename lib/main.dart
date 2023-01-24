import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_gen/gen_l10n/app_localizations.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:newapp/pages/gpt3.dart';
import 'package:newapp/pages/tts_player.dart';
import 'package:newapp/provider/social_sign_in_provider.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:newapp/pages/Auth/login.dart';
import 'package:provider/provider.dart';

bool isDarkMode = false;
bool rebuild = false;
bool maj = true;
bool isPopupActive = false;

/*const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();*/

const MethodChannel platform =
    MethodChannel('dexterx.dev/flutter_local_notifications_example');

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
  print('A bg msg: ${message.messageId}');
}

Future<void> _initHive() async {
  final Directory appDocDir = await getApplicationDocumentsDirectory();
  final String appDocPath = appDocDir.path;
  await Hive.initFlutter(appDocPath);

  //Registering Product subtypes
  /*if (Config.saveProducts) {
    Hive.registerAdapter(ProductsListAdapter());
    Hive.registerAdapter(ImagesAdapter());
    Hive.registerAdapter(CategoriesAdapter());
    Hive.registerAdapter(AttributesAdapter());
    Hive.registerAdapter(ProductVariationAdapter());
    Hive.registerAdapter(VariationAttributesAdapter());
    Hive.registerAdapter(ProductAdapter());

    Hive.openBox<ProductsList>('products');
  }

  Hive.registerAdapter(CouponAdapter());

  Hive.openBox<Coupon>('allCoupons');
  Hive.openBox('userCoupons');
  Hive.openBox('usedCoupons');

  Hive.registerAdapter(CartItemAdapter());

  Hive.openBox<CartItem>('cartItem');*/
}

void main() async {
  final appleSignInAvailable = await AppleSignInAvailable.check();
  runApp(
    Provider<AppleSignInAvailable>.value(
      value: appleSignInAvailable,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => SocialSignInProvider(),
          child: LoginPage(),
        ),
        ChangeNotifierProvider(
          create: (context) => TTSPlayerProvider(),
          child: Gpt3Page(),
        )
      ],
      child: MaterialApp(
        title: 'Login Page',
        home: Gpt3Page(),
      ),
    );
    // return MaterialApp(
    //   title: 'Login Page',
    //   home: LoginPage(),
    // );
  }
}
