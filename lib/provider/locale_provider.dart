import 'package:ai_pastor/services/local_services.dart';
import 'package:flutter/cupertino.dart';

import '../l10n/l10n.dart';

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;
  Locale? get locale => _locale;

  void setLocale(Locale locale) {
    if (!L10n.all.contains(locale)) return;
    _locale = locale;
    LocalServices.setLanguage(locale.languageCode);
    notifyListeners();
  }

  void setLocaleInit(Locale locale) {
    if (!L10n.all.contains(locale)) return;
    _locale = locale;
    LocalServices.setLanguage(locale.languageCode);
  }

  void notify() {
    notifyListeners();
  }

  void clearLocale() {
    _locale = null;
    LocalServices.clearLanguage();
    notifyListeners();
  }
}
