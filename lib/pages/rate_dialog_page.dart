import 'package:flutter/material.dart';
import 'package:rate_my_app/rate_my_app.dart';

class RateDialogPage extends StatefulWidget {
  const RateDialogPage({Key? key, required this.rateMyApp}) : super(key: key);
  final RateMyApp rateMyApp;

  @override
  State<RateDialogPage> createState() => _RateDialogPageState();
}

class _RateDialogPageState extends State<RateDialogPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        child: const Text("rate app"),
        onPressed: () {
          widget.rateMyApp.showStarRateDialog(
            context,
            title: "Your opinion on the app",
            message: "Are you satisfied with your Prem'Market application?",
            starRatingOptions: const StarRatingOptions(initialRating: 4),
            actionsBuilder: actionsBuilder,
          );
        },
      ),
    );
  }

  List<Widget> actionsBuilder(BuildContext context, double? stars) =>
      stars == null
          ? [_buildCancelButton()]
          : [_buildOkButton(), _buildCancelButton()];

  Widget _buildOkButton() => RateMyAppRateButton(
        widget.rateMyApp,
        text: "OK",
      );

  Widget _buildCancelButton() => RateMyAppNoButton(
        widget.rateMyApp,
        text: "CANCEL",
      );
}
