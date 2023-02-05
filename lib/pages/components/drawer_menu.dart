import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rate_my_app/rate_my_app.dart';
import '/constants.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({this.rateMyApp, Key? key}) : super(key: key);
  final RateMyApp? rateMyApp;
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
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        "Jacob",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
                _buildButton(
                  const Icon(Icons.help_outline),
                  "How it Works",
                ),
                _buildButton(
                  const Icon(Icons.monetization_on_outlined),
                  "Donate",
                ),
                _buildButton(
                    const Icon(Icons.star_outline_outlined), "Rate the app",
                    onTap: () {
                  widget.rateMyApp?.showStarRateDialog(
                    context,
                    title: "Rate this App",
                    message:
                        "Please give us your feedback on the app, to help us improve our services.",
                    starRatingOptions:
                        const StarRatingOptions(initialRating: 4),
                    actionsBuilder: actionsBuilder,
                  );

                  if (widget.rateMyApp == null) {
                    Fluttertoast.showToast(
                      msg: "Works only from the Chat Page",
                    );
                  }
                }),
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
          : [_buildOkButton(stars), _buildLaterButton(), _buildCancelButton()];

  Widget _buildOkButton(double? stars) => TextButton(
        onPressed: () async {
          if (stars != null) {
            if (stars >= 4) {
              widget.rateMyApp!.launchStore();
            }
            const event = RateMyAppEventType.rateButtonPressed;
            await widget.rateMyApp!.callEvent(event);
            Fluttertoast.showToast(
              msg: "Thanks for your review!",
            );
            Navigator.of(context).pop();
          }
        },
        child: Text("OK"),
      );

  Widget _buildLaterButton() => TextButton(
        onPressed: () async {
          const event = RateMyAppEventType.laterButtonPressed;
          await widget.rateMyApp!.callEvent(event);
          Navigator.of(context).pop();
        },
        child: Text("LATER"),
      );

  Widget _buildCancelButton() => TextButton(
        onPressed: () async {
          const event = RateMyAppEventType.noButtonPressed;
          await widget.rateMyApp!.callEvent(event);
          Navigator.of(context).pop();
        },
        child: Text("CANCEL"),
      );
}
