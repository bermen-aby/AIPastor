import 'package:flutter/material.dart';

// ignore: avoid_classes_with_only_static_members
class L10n {
  static final all = [
    const Locale('fr'),
    const Locale('en'),
  ];

  static String getLanguage(String languageCode) {
    switch (languageCode) {
      case 'fr':
        return 'Français';
      case 'en':
        return "English";
      default:
        return "Français";
    }
  }

  static Locale getLocale(String languageCode) {
    switch (languageCode) {
      case 'fr':
        return all.first;
      case 'en':
        return all.last;
      default:
        return all.first;
    }
  }
}
