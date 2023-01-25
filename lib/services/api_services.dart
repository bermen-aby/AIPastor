import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

String apiKey = "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";
String replyModel = "text-davinci-003"; //'text-curie-001'; //
String summaryModel = "text-curie-001";
int maxTokens = 256;
String stop = ".";

class APIService {
  final _speech = SpeechToText();

  Future<String> generateReply(String prompt, {String? context}) async {
    try {
      Response response = await Dio().post(
        'https://api.openai.com/v1/completions',
        data: {
          "model": replyModel,
          "prompt":
              "You are Pastor Jacob. Continue the discussion by replying to this: $prompt",
          "max_tokens": maxTokens,
        },
        options: Options(
          headers: {
            //HttpHeaders.contentTypeHeader: "application/json",
            HttpHeaders.authorizationHeader: "Bearer $apiKey",
          },
        ),
      );
      if (response.statusCode == 200) {
        var generatedText = response.data['choices'][0]['text'];
        return removeFirstNewline(generatedText);
      } else {
        throw Exception(
            "Failed to generate reply. Status code: ${response.statusCode}");
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return "Error generating reply: $e";
    }
  }

  Future<String> generateSummary(String text) async {
    try {
      Response response = await Dio().post(
        'https://api.openai.com/v1/completions',
        data: {
          "prompt": "Please summarize this text: $text",
          "temperature": 0.5,
          "max_tokens": 100,
          "top_p": 1,
          "stop": "\n",
          "model": "text-curie-001",
        },
        options: Options(
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            HttpHeaders.authorizationHeader: "Bearer $apiKey",
          },
        ),
      );
      if (response.statusCode == 200) {
        var generatedText = response.data['choices'][0]['text'];
        return removeEmptyLines(generatedText);
      } else {
        throw Exception(
            "Failed to generate summary. Status code: ${response.statusCode}");
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return "Error generating Summary: $e";
    }
  }

  Future<String> generateTitle(String text) async {
    try {
      Response response = await Dio().post(
        'https://api.openai.com/v1/completions',
        data: {
          "prompt":
              "in less than six words, give a title to this message: $text",
          "temperature": 0.5,
          "max_tokens": 20,
          "model": "text-curie-001",
        },
        options: Options(
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            HttpHeaders.authorizationHeader: "Bearer $apiKey",
          },
        ),
      );
      if (response.statusCode == 200) {
        var generatedText = response.data['choices'][0]['text'];
        return removeEmptyLines(generatedText);
      } else {
        throw Exception(
            "Failed to generate summary. Status code: ${response.statusCode}");
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return "Error generating Summary: $e";
    }
  }

  String removeFirstNewline(String text) {
    if (text.startsWith('\n')) {
      text = text.substring(1);
    }
    return text;
  }

  String removeEmptyLines(String text) {
    return text.replaceAll(RegExp(r'^\s*\n', multiLine: true), '');
  }

  Future<bool> toggleRecording({
    required Function(String text) onResult,
    required ValueChanged<bool> onListening,
  }) async {
    if (_speech.isListening) {
      _speech.stop();
      return true;
    }
    final isAvailable = await _speech.initialize(
      onStatus: (status) => onListening(_speech.isListening),
      onError: (errorNotification) =>
          debugPrint('Error listening $errorNotification'),
    );
    if (isAvailable) {
      _speech.listen(
        onResult: (result) => onResult(result.recognizedWords),
      );
    }

    return isAvailable;
  }
}
