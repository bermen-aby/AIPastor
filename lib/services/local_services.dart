import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalServices {
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

  static Future<bool> firstVisit() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getBool('firstVisit') == null ||
        prefs.getBool('firstVisit') == true) {
      prefs.setBool('firstVisit', false);
      return true;
    }
    return false;
  }

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

  static Future<bool> getAutoPlay() async {
    final prefs = await SharedPreferences.getInstance();
    bool autoPlay;
    prefs.getBool("autoplay") == false ? autoPlay = false : autoPlay = true;
    return autoPlay;
  }

  static Future<bool?> setAutoPlay(
    bool? autoPlay,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    if (autoPlay == true) {
      return prefs.setBool("autoplay", true);
    }
    return prefs.setBool("autoplay", false);
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

  static Future<bool> setLaunchCount() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.setInt('launchCount', (prefs.getInt('launchCount') ?? 0) + 1);
  }

  static Future<int> getLaunchCount() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getInt('launchCount') ?? 0;
  }
}
