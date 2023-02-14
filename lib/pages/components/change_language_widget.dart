// ignore_for_file: must_be_immutable

import 'package:ai_pastor/constants.dart';
import 'package:ai_pastor/provider/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';

class ChangeLanguageWidget extends StatelessWidget {
  ChangeLanguageWidget({super.key});
  final items = ["Français", "English"];
  String? value;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    if (locale.languageCode == "fr") {
      value = items.first;
    } else {
      value = items.last;
    }

    return DropdownButton<String>(
      value: value,
      items: items.map(buildMenuItem).toList(),
      onChanged: (value) {
        if (value == "Français") {
          localeProvider.setLocale(L10n.all.first);
        }
        if (value == "English") {
          localeProvider.setLocale(L10n.all.last);
        }
        this.value = value;
      },
    );
  }

  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
        value: item,
        child: Text(
          item,
          style: textButtonStyle,
        ),
      );
}
