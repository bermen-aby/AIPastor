// ignore_for_file: use_build_context_synchronously

import 'package:ai_pastor/pages/components/change_language_widget.dart';
import 'package:ai_pastor/pages/components/change_theme_button_widget.dart';
import 'package:ai_pastor/pages/onboarding/onboarding_page.dart';
import 'package:ai_pastor/pages/onboarding/slides/donation.dart';
import 'package:ai_pastor/utils/translate.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:new_version/new_version.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import '../../provider/theme_provider.dart';
import '/constants.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({required this.rateMyApp, Key? key}) : super(key: key);
  final RateMyApp rateMyApp;
  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  final textLight =
      const TextStyle(fontWeight: FontWeight.w700, color: kPrimaryColor);
  final textDark = const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w700,
  );
  VersionStatus? status;
  String versionText = "";
  bool canUpdate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  init() async {
    status = await newVersion.getVersionStatus().then(
      (value) {
        if (value != null) {
          versionText = value.localVersion;
          if (value.canUpdate) {
            canUpdate = true;
          }
        }
        return null;
      },
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Material(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              // ignore: cast_nullable_to_non_nullable
              colors: [kContentColorLightTheme, kPrimaryColor],
              begin: FractionalOffset.topLeft,
              end: FractionalOffset.centerRight,
            ),
          ),
          child: InkWell(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                      top: 60,
                      bottom: 20,
                    ),
                    width: double.infinity,
                    //height: 600,
                    child: Column(
                      children: const [
                        CircleAvatar(
                          radius: 120,
                          backgroundImage: AssetImage(
                            "assets/images/pastor.png",
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          "AI PASTOR",
                          style: textButtonStyle,
                        ),
                        Text(
                          "Jacob",
                          style: textButtonStyle,
                        ),
                      ],
                    ),
                  ),
                  _buildButton(
                    const Icon(Icons.help_outline),
                    t(context).howItWorks,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OnboardingPage(
                            rateMyApp: widget.rateMyApp,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildButton(
                    const Icon(Icons.monetization_on_outlined),
                    t(context).donate,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Donation(
                            slideNumber: 3,
                            donatePageOnly: true,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildButton(const Icon(Icons.star_outline_outlined),
                      t(context).rateTheApp, onTap: () {
                    widget.rateMyApp.showStarRateDialog(
                      context,
                      title: t(context).rateTheApp,
                      message: t(context).rateAppMessage,
                      starRatingOptions:
                          const StarRatingOptions(initialRating: 4),
                      actionsBuilder: actionsBuilder,
                    );
                  }),
                  const ChangeThemeButtonWidget(),
                  const SizedBox(
                    height: 10,
                  ),
                  ChangeLanguageWidget(setstate: () {
                    setState(() {});
                  }),
                  const SizedBox(
                    height: 45,
                  ),
                  Text(
                    "Version $versionText",
                    style: const TextStyle(color: Colors.white),
                  ),
                  if (canUpdate)
                    TextButton(
                      onPressed: _showUpdate,
                      child: Text(t(context).update),
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _showUpdate() {
    newVersion.showUpdateDialog(
      context: context,
      versionStatus: status!,
      dialogText: t(context).updateText,
      dialogTitle: t(context).updateAvailable,
      dismissButtonText: t(context).later,
      updateButtonText: t(context).update,
    );
  }

  Widget _buildButton(Icon icon, String title,
      {Widget? goto, Function? onTap}) {
    final theme = Provider.of<ThemeProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
          onPressed: () {
            if (goto != null) {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => goto,
              ));
            }
            if (onTap != null) {
              onTap();
            }
          },
          child: Row(
            children: [
              icon,
              const SizedBox(
                width: 10,
              ),
              Text(
                title,
                style: theme.isDarkMode ? textDark : textLight,
              ),
            ],
          )),
    );
  }

  List<Widget> actionsBuilder(BuildContext context, double? stars) =>
      stars == null
          ? [_buildCancelButton()]
          : [
              _buildCancelButton(),
              _buildLaterButton(),
              _buildOkButton(stars),
            ];

  Widget _buildOkButton(double? stars) => TextButton(
        onPressed: () async {
          if (stars != null) {
            if (stars >= 4) {
              widget.rateMyApp.launchStore();
            }
            const event = RateMyAppEventType.rateButtonPressed;
            await widget.rateMyApp.callEvent(event);
            Fluttertoast.showToast(
              msg: t(context).thanksForRating,
            );
            Navigator.of(context).pop();
          }
        },
        child: Text(
          t(context).ok.toUpperCase(),
          style: buttonStyle,
        ),
      );

  Widget _buildLaterButton() => TextButton(
        onPressed: () async {
          const event = RateMyAppEventType.laterButtonPressed;
          await widget.rateMyApp.callEvent(event);
          Navigator.of(context).pop();
        },
        child: Text(
          t(context).later.toUpperCase(),
          style: buttonStyle,
        ),
      );

  Widget _buildCancelButton() => TextButton(
        onPressed: () async {
          const event = RateMyAppEventType.noButtonPressed;
          await widget.rateMyApp.callEvent(event);
          Navigator.of(context).pop();
        },
        child: Text(
          t(context).cancel.toUpperCase(),
          style: buttonStyle,
        ),
      );
}
