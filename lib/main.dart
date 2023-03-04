import 'package:ai_pastor/components/rate_app_init_widget.dart';
import 'package:ai_pastor/constants.dart';
import 'package:ai_pastor/l10n/l10n.dart';
import 'package:ai_pastor/pages/onboarding/onboarding_page.dart';
import 'package:ai_pastor/provider/locale_provider.dart';
import 'package:ai_pastor/provider/selection_provider.dart';
import 'package:ai_pastor/services/local_services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '/pages/chat_page/chat_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'provider/theme_provider.dart';
import 'theme.dart';
import 'variables.dart';

/*const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();*/

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   try {
//     await Firebase.initializeApp();
//   } on FirebaseException catch (e) {
//     if (e.code == 'duplicate-app') {
//     } else {
//       rethrow;
//     }
//   } catch (e) {
//     rethrow;
//   }
//   if (kDebugMode) {
//     print('A bg msg: ${message.messageId}');
//   }
// }

// ---------------------------------------------------------
// MAIN

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  isDarkModeVar = await LocalServices.isDarkMode();
  firstVisitVar = await LocalServices.firstVisit();
  await LocalServices.setLaunchCount();
  MobileAds.instance.initialize();
  runApp(
    const MyApp(),
  );
}

// ---------------------------------------------------------
// APP

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<dynamic> init() async {
    serverData = await apiServices.fetchPosts();
    print("LOG ${serverData.storeVersion}");

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider();
    init();
    return ChangeNotifierProvider(
      create: (context) {
        if (!isDarkModeVar) {
          themeProvider.toggleTheme(false);
        } else {
          themeProvider.toggleTheme(true);
        }
        return themeProvider;
      },
      builder: (context, _) {
        SystemChrome.setSystemUIOverlayStyle(
            isDarkModeVar ? darkOverlayStyle : lightOverlayStyle);

        final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => SelectionProvider(),
            ),
          ],
          child: ChangeNotifierProvider(
            create: (context) => LocaleProvider(),
            builder: (context, child) {
              final localeProvider = Provider.of<LocaleProvider>(context);
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: lightThemeData(context),
                darkTheme: darkThemeData(context),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: L10n.all,
                locale: localeProvider.locale,
                themeMode: themeProvider.themeMode,
                title: 'AI PASTOR',
                home: JelloIn(
                  child: AnimatedSplashScreen(
                    function: init,
                    backgroundColor: Theme.of(context).colorScheme.background,
                    splashIconSize: 1942,
                    splash: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.fitHeight,
                          image: AssetImage(
                            "assets/images/splashscreen.png",
                          ),
                        ),
                      ),
                    ),
                    nextScreen: RateAppInitWidget(
                      builder: (rateMyApp) => firstVisitVar
                          ? OnboardingPage(
                              rateMyApp: rateMyApp,
                            )
                          : ChatPage(
                              rateMyApp: rateMyApp,
                            ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
