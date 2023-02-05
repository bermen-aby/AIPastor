import 'package:flutter/material.dart';
import 'package:rate_my_app/rate_my_app.dart';

import '../constants.dart';

class RateAppInitWidget extends StatefulWidget {
  const RateAppInitWidget({Key? key, required this.builder}) : super(key: key);
  final Widget Function(RateMyApp) builder;

  @override
  _RateAppInitWidgetState createState() => _RateAppInitWidgetState();
}

class _RateAppInitWidgetState extends State<RateAppInitWidget> {
  RateMyApp? rateMyApp;
  @override
  Widget build(BuildContext context) {
    return RateMyAppBuilder(
      rateMyApp: RateMyApp(
        appStoreIdentifier: appleStoreId,
        googlePlayIdentifier: playStoreId,
        minDays: 2,
        minLaunches: 2,
        remindDays: 21,
        remindLaunches: 3,
      ),
      onInitialized: (context, rateMyApp) {
        setState(() {
          this.rateMyApp = rateMyApp;
        });

        // if (rateMyApp.shouldOpenDialog) {
        //   rateMyApp.showRateDialog(context);
        // }
      },
      builder: (context) {
        if (rateMyApp == null) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return widget.builder(rateMyApp!);
        }
      },
    );
  }
}
