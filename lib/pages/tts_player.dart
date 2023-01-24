import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
//import 'package:flutter_tts/flutter_tts_web.dart';

// class TTSPlayer extends StatefulWidget {
//   const TTSPlayer({super.key});

//   @override
//   _TTSPlayerState createState() => _TTSPlayerState();
// }

// class _TTSPlayerState extends State<TTSPlayer> {

class TTSPlayerProvider with ChangeNotifier {
  String _text =
      "The Griffith Observatory is the most iconic building in Los Angeles, perched high in the Hollywood Hills, 1,134 feet above sea level.";

  bool _isPlaying = false;
  String _currentWord = '';
  FlutterTts _flutterTts = FlutterTts();
  //TtsState _ttsState = TtsState.stopped;

  String get text => _text;
  String get currentWord => _currentWord;
  bool get isPlaying => _isPlaying;

  set text(String msg) {
    _text = msg;
  }

  set currentWord(String msg) {
    currentWord = msg;
  }

  set isPlaying(bool msg) {
    _isPlaying = msg;
  }

  // @override
  // void initState() {
  //   super.initState();
  //   initializeTts();
  // }

  initializeTts() async {
    _flutterTts = FlutterTts();
    List<dynamic> languages = await _flutterTts.getLanguages;
    print(languages);

    await _flutterTts.setLanguage("en-US");

    await _flutterTts.setSpeechRate(1.0);

    await _flutterTts.setVolume(1.0);

    await _flutterTts.setPitch(1.0);

    await _flutterTts.isLanguageAvailable("en-US");

    if (Platform.isAndroid) {
      _flutterTts.setInitHandler(() {
        //setState(() {
        //_ttsState = TtsState.stopped;
        //});
      });
    } else if (Platform.isIOS) {
      await _flutterTts.setSharedInstance(true);
      await _flutterTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.ambient,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers
          ],
          IosTextToSpeechAudioMode.voicePrompt);
      //setTtsLanguage();
    } else if (kIsWeb) {
      //not-supported by plugin
    }
    _flutterTts.setStartHandler(() {
      //setState(() {
      _isPlaying = true;
      //_ttsState = TtsState.playing;
      //});
    });
    _flutterTts.setCompletionHandler(() {
      //setState(() {
      _isPlaying = false;
      //_ttsState = TtsState.stopped;
      //});
    });
    _flutterTts.setProgressHandler(
        (String text, int startOffset, int endOffset, String word) {
      //setState(() {
      _currentWord = word;
      //});
    });
    _flutterTts.setErrorHandler((err) {
      //setState(() {
      print("error occurred: " + err);
      _isPlaying = false;
      //_ttsState = TtsState.stopped;
      // });
    });
    _flutterTts.setCancelHandler(() {
      //setState(() {
      //_ttsState = TtsState.stopped;
      _isPlaying = false;
      //});
    });

// Android, iOS and Web
    _flutterTts.setPauseHandler(() {
      //setState(() {
      //_ttsState = TtsState.paused;
      _isPlaying = false;
      // });
    });

    _flutterTts.setContinueHandler(() {
      //setState(() {
      //_ttsState = TtsState.continued;
      _isPlaying = true;
      // });
    });
  }

  Future speak() async {
    var result = await _flutterTts.speak(_text);
    if (result == 1) _isPlaying = true;
  }

  Future stop() async {
    var result = await _flutterTts.stop();
    if (result == 1) _isPlaying = false;
  }

  @override
  void dispose() {
    super.dispose();
    _flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
