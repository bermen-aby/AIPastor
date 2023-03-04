import 'package:ai_pastor/services/local_services.dart';
import 'package:ai_pastor/variables.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../provider/theme_provider.dart';

class ChangeThemeButtonWidget extends StatelessWidget {
  const ChangeThemeButtonWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: ListTile(
        title: Text(
          AppLocalizations.of(context)!.darkMode,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        hoverColor: Colors.grey,
        onTap: () {},
        leading: const Icon(Icons.dark_mode_outlined, color: Colors.white),
        trailing: Switch.adaptive(
          trackColor: MaterialStateProperty.resolveWith((states) =>
              themeProvider.isDarkMode ? Colors.black : Colors.white),
          //activeTrackColor: Colors.white,
          thumbColor: MaterialStateProperty.all<Color>(Colors.green),
          value: themeProvider.isDarkMode,
          onChanged: (value) {
            final provider = Provider.of<ThemeProvider>(context, listen: false);
            LocalServices.setDarkMode(value);
            provider.toggleTheme(value);
            isDarkModeVar = value;
          },
        ),
      ),
    );
  }
}
