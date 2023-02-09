import 'package:ai_pastor/pages/components/change_theme_button_widget.dart';
import 'package:ai_pastor/pages/onboarding/onboarding_page.dart';
import 'package:ai_pastor/pages/onboarding/slides/donation.dart';
import 'package:ai_pastor/pages/onboarding/slides/slides.dart';
import 'package:ai_pastor/utils/translate.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rate_my_app/rate_my_app.dart';
import '/constants.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({required this.rateMyApp, Key? key}) : super(key: key);
  final RateMyApp rateMyApp;
  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(Icon icon, String title,
      {Widget? goto, Function? onTap}) {
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
              Text(title),
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
