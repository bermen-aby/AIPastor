import 'package:ai_pastor/constants.dart';

//import 'constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// This is our  main focus
// Let's apply light and dark theme on our app
// Now let's add dark theme on our app

ThemeData lightThemeData(BuildContext context) {
  // return FlexThemeData.light(
  //     scheme: FlexScheme.bahamaBlue,
  //     surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
  //     blendLevel: 9,
  //     subThemesData: const FlexSubThemesData(
  //       blendOnLevel: 10,
  //       blendOnColors: false,
  //       appBarBackgroundSchemeColor: SchemeColor.inversePrimary,
  //     ),
  //     visualDensity: FlexColorScheme.comfortablePlatformDensity,
  //     useMaterial3: true,
  //     swapLegacyOnMaterial3: true,
  //     // To use the playground font, add GoogleFonts package and uncomment
  //     fontFamily: GoogleFonts.notoSans().fontFamily,
  //     //background: kContentColorLightTheme,
  //     scaffoldBackground: kScaffoldBackgroundColorLight);

  return ThemeData.light().copyWith(
    useMaterial3: true,
    primaryColor: kPrimaryColor,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: appBarLightTheme,
    iconTheme: const IconThemeData(color: kContentColorLightTheme),
    textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme)
        .apply(bodyColor: kContentColorLightTheme),
    colorScheme: const ColorScheme.light(
      primary: kPrimaryColor,
      secondary: kSecondaryColor,
      error: kErrorColor,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: kContentColorLightTheme.withOpacity(0.7),
      unselectedItemColor: kContentColorLightTheme.withOpacity(0.32),
      selectedIconTheme: const IconThemeData(color: kPrimaryColor),
      showUnselectedLabels: true,
    ),
  );
}

ThemeData darkThemeData(BuildContext context) {
  // // Bydefault flutter provie us light and dark theme
  // // we just modify it as our need
  // return FlexThemeData.dark(
  //   scheme: FlexScheme.bahamaBlue,
  //   surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
  //   blendLevel: 15,
  //   subThemesData: const FlexSubThemesData(
  //     blendOnLevel: 20,
  //     appBarBackgroundSchemeColor: SchemeColor.inversePrimary,
  //   ),
  //   visualDensity: FlexColorScheme.comfortablePlatformDensity,
  //   useMaterial3: true,
  //   swapLegacyOnMaterial3: true,
  //   // To use the Playground font, add GoogleFonts package and uncomment
  //   fontFamily: GoogleFonts.notoSans().fontFamily,
  //   background: kContentColorDarkTheme,
  // );

  return ThemeData.dark().copyWith(
    useMaterial3: true,
    primaryColor: kPrimaryColor,
    scaffoldBackgroundColor: kContentColorLightTheme,
    appBarTheme: appBarDarkTheme,
    iconTheme: const IconThemeData(color: kContentColorDarkTheme),
    textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme)
        .apply(bodyColor: kContentColorDarkTheme),
    colorScheme: const ColorScheme.dark().copyWith(
      primary: kPrimaryColor,
      secondary: kSecondaryColor,
      error: kErrorColor,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: kContentColorDarkTheme,
      selectedItemColor: Colors.white70,
      unselectedItemColor: kContentColorDarkTheme.withOpacity(0.32),
      selectedIconTheme: const IconThemeData(color: kPrimaryColor),
      showUnselectedLabels: true,
    ),
  );
}

const appBarLightTheme = AppBarTheme(
    centerTitle: false, elevation: 0, backgroundColor: Color(0xFF99CCF9));
const appBarDarkTheme = AppBarTheme(
    centerTitle: false, elevation: 0, backgroundColor: kPrimaryColor);
