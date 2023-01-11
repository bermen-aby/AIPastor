// ignore_for_file: avoid_positional_boolean_parameters

import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:shared_preferences/shared_preferences.dart';

// ignore: avoid_classes_with_only_static_members
class SharedService {
  static Future<bool> hasInternet() async {
    // final bool response = await InternetConnectionChecker().hasConnection;
    // return response;
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    } else {
      return true;
    }
  }

  // static Future<Position> _determinePosition() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;

  //   // Test if location services are enabled.
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     // Location services are not enabled don't continue
  //     // accessing the position and request users of the
  //     // App to enable the location services.
  //     return Future.error('Location services are disabled.');
  //   }

  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       // Permissions are denied, next time you could try
  //       // requesting permissions again (this is also where
  //       // Android's shouldShowRequestPermissionRationale
  //       // returned true. According to Android guidelines
  //       // your App should show an explanatory UI now.
  //       return Future.error('Location permissions are denied');
  //     }
  //   }

  //   if (permission == LocationPermission.deniedForever) {
  //     // Permissions are denied forever, handle appropriately.
  //     return Future.error(
  //       'Location permissions are permanently denied, we cannot request permissions.',
  //     );
  //   }

  //   // When we reach here, permissions are granted and we can
  //   // continue accessing the position of the device.
  //   return Geolocator.getCurrentPosition();
  // }

  // Future<Map<String, dynamic>> getAddressFromLatLong(Position position) async {
  //   final List<Placemark> placemarks =
  //       await placemarkFromCoordinates(position.latitude, position.longitude);
  //   print(placemarks);
  //   final Placemark place = placemarks[0];
  //   final Map<String, dynamic> address = {
  //     'street': '${place.street}',
  //     'subLocality': '${place.subLocality}',
  //     'locality': '${place.locality}',
  //     'postCode': '${place.postalCode}',
  //     'country': '${place.country}'
  //   };
  //   return address;
  // }

  static Future<bool> firstVisit() async {
    final prefs = await SharedPreferences.getInstance();
    // ignore: avoid_bool_literals_in_conditional_expressions
    if (prefs.getBool('firstVisit') == null ||
        prefs.getBool('firstVisit') == true) {
      prefs.setBool('firstVisit', false);
      return true;
    }
    return false;
  }

//----------------------------------------------------------
  // LOGIN
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    // ignore: avoid_bool_literals_in_conditional_expressions
    return prefs.getString("login_details") != null &&
            prefs.getString("login_details") != ""
        ? true
        : false;
  }

  // static Future<LoginResponseModel?> loginDetails() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getString("login_details") != null &&
  //           prefs.getString("login_details") != ""
  //       ? LoginResponseModel.fromJson(
  //           jsonDecode(prefs.getString("login_details")!)
  //               as Map<String, dynamic>,
  //         )
  //       : null;
  // }

  // static Future<bool?> setLoginDetails(
  //   LoginResponseModel? loginResponseModel,
  // ) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   if (loginResponseModel != null) {
  //     return prefs.setString(
  //       "login_details",
  //       jsonEncode(loginResponseModel.toJson()),
  //     );
  //   }
  //   return prefs.setString(
  //     "login_details",
  //     "",
  //   );
  // }

  // static Future<void> logOut() async {
  //   await setLoginDetails(null);
  //   await setDarkMode(null);
  // }

//----------------------------------------------------------
  // DARK MODE
  static Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    bool isDarkMode;
    prefs.getBool("dark_mode") == true ? isDarkMode = true : isDarkMode = false;
    return isDarkMode;
  }

  static Future<bool?> setDarkMode(
    bool? isDarkMode,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    if (isDarkMode == true) {
      return prefs.setBool("dark_mode", true);
    }
    return prefs.setBool("dark_mode", false);
  }

//----------------------------------------------------------
  // SAME SHIPPING AS BILLING (ADRESSES)
  static Future<bool> isDifferentShipping() async {
    final prefs = await SharedPreferences.getInstance();
    bool isSameShipping;
    prefs.getBool("different_shipping") == true
        ? isSameShipping = true
        : isSameShipping = false;
    return isSameShipping;
  }

  static Future<bool?> setDifferentShipping(
    bool? sameShipping,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    if (sameShipping == true) {
      return prefs.setBool("different_shipping", true);
    }
    return prefs.setBool("different_shipping", false);
  }

//----------------------------------------------------------
  // LANGUAGE
  static Future<String?> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("locale");
  }

  static Future<bool?> setLanguage(String locale) async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.setString("locale", locale);
  }

  static Future<bool> clearLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove("locale");
  }

  //----------------------------------------------------------
  // CACHE VERSION

  static Future<double?>? getProductsLocalCacheVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble("productsCache");
  }

  static Future<bool?> setProductsLocalCacheVersion(double version) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setDouble("productsCache", version);
  }

  // static Future<bool> isCacheActive() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   bool _isCacheActive;
  //   prefs.getBool("isCacheActive") == false
  //       ? _isCacheActive = false
  //       : _isCacheActive = true;
  //   return _isCacheActive;
  // }

  // static Future<bool?> setCacheActive(bool trigger) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.setBool("isCacheActive", trigger);
  // }

  //----------------------------------------------------------
  // LAST LOGIN
  static Future<int?>? getLastLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("lastLogin");
  }

  static Future<bool?> setLastLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    return prefs.setInt("lastLogin", now.day);
  }
}
