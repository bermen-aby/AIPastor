import 'package:ai_pastor/constants.dart';
import 'package:ai_pastor/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/translate.dart';

class Donation extends StatefulWidget {
  const Donation({super.key, required this.slideNumber, this.donatePageOnly});
  final int slideNumber;
  final bool? donatePageOnly;

  @override
  State<Donation> createState() => _DonationState();
}

class _DonationState extends State<Donation> {
  String title = "";
  String description = "";
  String asset = "assets/lottie/dots_loading.json";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initText());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: SingleChildScrollView(
        child: Container(
          color: kPrimaryColor,
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 80),
                Text(
                  title,
                  style: introTitle,
                  textAlign: TextAlign.center,
                ),
                Container(
                  padding: const EdgeInsets.all(kDefaultPadding),
                  child: Text(
                    description,
                    style: introDetails,
                    textAlign: TextAlign.center,
                  ),
                ),
                if (widget.slideNumber == 3)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: kDefaultPadding * 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        widget.donatePageOnly != null
                            ? widget.donatePageOnly == true
                                ? Row(
                                    children: [
                                      _laterButton(),
                                      const SizedBox(width: 20),
                                      _donateButton(),
                                    ],
                                  )
                                : _donateButton()
                            : _donateButton(),
                      ],
                    ),
                  ),
                Lottie.asset(
                  asset,
                  repeat: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  initText() {
    switch (widget.slideNumber) {
      case 1:
        title = t(context).screen1Title;
        description = t(context).screen1Description;
        asset = "assets/lottie/screen1.json";
        break;
      case 2:
        title = t(context).screen2Title;
        description = t(context).screen2Description;
        asset = "assets/lottie/screen2.json";
        break;
      case 3:
        title = t(context).screen3Title;
        description = t(context).screen3Description;
        asset = "assets/lottie/money_donation.json";
        break;
      case 4:
        title = t(context).screen4Title;
        description = t(context).screen4Description;
        asset = "assets/lottie/screen4.json";
        break;
    }
    setState(() {});
  }

  Widget _laterButton() {
    final theme = Provider.of<ThemeProvider>(context, listen: false);
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: Text(
        t(context).later.toUpperCase(),
        style: TextStyle(
          color: theme.isDarkMode ? Colors.white : kPrimaryColor,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _donateButton() {
    return ElevatedButton(
      onPressed: () async {
        final url = Uri.parse("https://paypal.me/AIPastorJacob");
        if (await canLaunchUrl(url)) {
          launchUrl(url);
        }
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: kSuccessColor,
          shape: const BeveledRectangleBorder()),
      child: Text(
        t(context).donate.toUpperCase(),
        style: textButtonStyle,
      ),
    );
  }
}
