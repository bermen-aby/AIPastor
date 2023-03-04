import 'package:ai_pastor/pages/chat_page/chat_page.dart';
import 'package:ai_pastor/utils/translate.dart';

import '../../constants.dart';
import '../../variables.dart';
import '../components/change_language_widget.dart';
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
    init();
  }

  init() {
    nb = firstVisitVar ? 2 : 3;
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
              if (!firstVisitVar) const Slides(slideNumber: 3),
              const Slides(slideNumber: 4),
            ],
          ),
          _languageSelector(),
          _navigation(),
        ],
      ),
    );
  }

  Widget _languageSelector() {
    return Container(
      alignment: const Alignment(0, 0.8),
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(),
          ChangeLanguageWidget(setstate: () {
            setState(() {});
          }),
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
            count: firstVisitVar ? 3 : 4,
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
}
