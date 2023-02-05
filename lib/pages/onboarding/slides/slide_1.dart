import 'package:ai_pastor/constants.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Slide1 extends StatefulWidget {
  const Slide1({super.key});

  @override
  State<Slide1> createState() => _Slide1State();
}

class _Slide1State extends State<Slide1> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: Center(
        child: Stack(
          children: [
            //const SizedBox(height: 40),
            const Positioned(
              top: 0.2,
              child: Text(
                "WELCOME TO AI PASTOR!",
                style: introTitle,
                textAlign: TextAlign.center,
              ),
            ),
            Lottie.asset(
              "assets/lottie/message_delivery.json",
              repeat: true,
            ),
            Positioned(
              bottom: 0.6,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: const Text(
                  "This app is designed to provide answers to any questions about Christianity in a conversational manner with Pastor Jacob, an AI-powered assistant. Get ready to start your spiritual journey and deepen your understanding of the faith with the help of AI Pastor.",
                  style: introDetails,
                  maxLines: 6,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
