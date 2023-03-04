import 'dart:io';

import 'package:ai_pastor/secrets.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobServices {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return adMobBannerBlocID;
    } else if (Platform.isIOS) {
      return adMobBannerBlocID;
    }
    return adMobBannerBlocID;
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return adMobInterstitialIDAndroid;
    } else if (Platform.isIOS) {
      return adMobInterstitialIDAndroid;
    }
    return adMobInterstitialIDAndroid;
  }

  static final BannerAdListener bannerAdListener = BannerAdListener(
    onAdLoaded: (ad) => debugPrint("LOG: Ad Loaded"),
    onAdFailedToLoad: (ad, error) {
      ad.dispose();
      debugPrint("LOG: Ad failed to load: $error");
    },
    onAdOpened: (ad) => debugPrint("LOG: Ad Opened"),
    onAdClosed: (ad) => debugPrint("LOG: Ad closed"),
  );
}
