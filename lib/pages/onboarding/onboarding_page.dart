import 'package:ai_pastor/pages/chat_page/chat_page.dart';

import '../../variables.dart';
import 'slides/slide_1.dart';
import 'slides/slide_2.dart';
import 'slides/slide_3.dart';
import 'slides/slide_4.dart';
import 'package:ai_pastor/services/local_services.dart';
import 'package:flutter/material.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// ignore: must_be_immutable
class OnboardingPage extends StatefulWidget {
  OnboardingPage({super.key, RateMyApp? rateMyApp});

  RateMyApp? rateMyApp;

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
    nb = firstVisit ? 2 : 3;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              const Slide1(),
              const Slide2(),
              if (!firstVisit) const Slide3(),
              const Slide4(),
            ],
          ),
          _navigation(),
        ],
      ),
    );
  }

  Widget _navigation() {
    return Container(
      alignment: Alignment(0, 0.8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          currentPage != 0
              ? GestureDetector(
                  onTap: () {
                    _pageController.previousPage(
                      duration: Duration(microseconds: 500),
                      curve: Curves.easeIn,
                    );
                  },
                  child: Text("Previous"),
                )
              : SizedBox(),
          SmoothPageIndicator(
            controller: _pageController,
            count: firstVisit ? 3 : 4,
          ),
          GestureDetector(
            onTap: () {
              _pageController.nextPage(
                duration: Duration(microseconds: 500),
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
                    child: Text("START CHATTING"),
                  )
                : Text("Next"),
          ),
        ],
      ),
    );
  }
}
