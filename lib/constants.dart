import 'package:ai_pastor/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_version/new_version.dart';

const kPrimaryColor = Color(0xFF095D9E);
const kSecondaryColor = Color(0xFF9CD5F9);
const kContentColorLightTheme = Color(0xFF1D1D35);
const kContentColorDarkTheme = Color(0xFFF5FCF9);
const kWarninngColor = Color(0xFFF3BB1C);
const kErrorColor = Color(0xFFF03738);
const kSuccessColor = Colors.green;
const kScaffoldBackgroundColorLight = Color.fromARGB(255, 245, 245, 245);

const kDefaultPadding = 20.0;

const introTitle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 40,
  color: Colors.white,
);

const introSubTitle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 30,
  color: Colors.white,
);

const introDetails = TextStyle(
  fontWeight: FontWeight.w500,
  color: Colors.white70,
  fontSize: 20,
);

const textButtonStyle = TextStyle(
  fontWeight: FontWeight.w700,
  color: Colors.white,
  fontSize: 15,
);

const buttonStyle = TextStyle(
  fontWeight: FontWeight.w700,
  fontSize: 15,
);

const lightOverlayStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent, //Color(0xFF446084),
  statusBarIconBrightness: Brightness.light,
  systemNavigationBarColor: kPrimaryColor,
  systemNavigationBarIconBrightness: Brightness.light,
);

const darkOverlayStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent, //Color(0xFF446084),
  statusBarIconBrightness: Brightness.light,
  systemNavigationBarColor: kPrimaryColor,
  systemNavigationBarIconBrightness: Brightness.light,
);

const playStoreId = 'com.bermen.aipastor';
const appleStoreId = 'com.bermen.aipastor';

final newVersion = NewVersion(
  androidId: playStoreId, //"com.snapchat.android",
  iOSId: appleStoreId,
);

final APIService apiServices = APIService();

const MethodChannel platform =
    MethodChannel('dexterx.dev/flutter_local_notifications_example');
