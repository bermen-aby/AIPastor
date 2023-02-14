import 'package:ai_pastor/pages/chat_page/chat_page.dart';
import 'package:ai_pastor/utils/translate.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../provider/locale_provider.dart';
import '../../services/local_services.dart';
import '../../variables.dart';
import 'slides/slides.dart';
import 'package:flutter/material.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// ignore: must_be_immutable
class OnboardingPage extends StatefulWidget {
  OnboardingPage({super.key, required this.rateMyApp});

  RateMyApp rateMyApp;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  bool onLastPage = false;
  int nb = 2;
  int currentPage = 0;
  @override
  void initState() {
    super.initState();
    initLocale();
    init();
  }

  init() {
    nb = firstVisit ? 2 : 3;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == nb);
                currentPage = index;
              });
            },
            children: [
              const Slides(slideNumber: 1),
              const Slides(slideNumber: 2),
              if (!firstVisit) const Slides(slideNumber: 3),
              const Slides(slideNumber: 4),
            ],
          ),
          _navigation(),
        ],
      ),
    );
  }

  Widget _navigation() {
    return Container(
      alignment: const Alignment(0, 0.9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          currentPage != 0
              ? GestureDetector(
                  onTap: () {
                    _pageController.previousPage(
                      duration: const Duration(microseconds: 500),
                      curve: Curves.easeIn,
                    );
                  },
                  child: Text(
                    t(context).previous,
                    style: textButtonStyle,
                  ),
                )
              : const SizedBox(),
          SmoothPageIndicator(
            controller: _pageController,
            count: firstVisit ? 3 : 4,
            effect: const WormEffect(
              activeDotColor: Colors.green,
            ),
          ),
          GestureDetector(
            onTap: () {
              _pageController.nextPage(
                duration: const Duration(microseconds: 500),
                curve: Curves.easeIn,
              );
            },
            child: onLastPage
                ? ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            rateMyApp: widget.rateMyApp,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    child: Text(
                      t(context).startChatting,
                      style: buttonStyle,
                    ),
                  )
                : Text(
                    t(context).next,
                    style: textButtonStyle,
                  ),
          ),
        ],
      ),
    );
  }

  Future<bool> initLocale() async {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    await LocalServices.getLanguage().then((value) {
      if (value != null) {
        localeProvider.setLocale(Locale(value));
      } else {
        final locale = Localizations.localeOf(context);
        //localeProvider.setLocale(locale); simplifié plus bas
        LocalServices.setLanguage(locale.languageCode);
      }
    });
    return true;
  }
}
