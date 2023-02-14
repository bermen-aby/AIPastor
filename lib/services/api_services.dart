import 'dart:io';

import 'package:ai_pastor/models/message.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../secrets.dart';

String replyModel = "text-davinci-003"; //'text-curie-001'; //
String summaryModel = "text-curie-001";
int maxTokens = 256;
String stop = ".";
//Rajoute ta cle api ici
//String apiKey = "...";

class APIService {
  final _speech = SpeechToText();

  Future<String> generateReply(String prompt,
      {String? context, bool? french}) async {
    if (kDebugMode) {
      print("LOG: context: $context");
    }
    try {
      Response response = await Dio().post(
        "https://api.openai.com/v1/completions",
        data: {
          "model": replyModel,
          "prompt": french ?? false
              ? "Vous êtes une IA nommée Aimee. Poursuivez la discussion en répondant à cette question:\n$context Moi: $prompt ? \n AImee: "
              : "You are an AI named Aimee. Continue the discussion by replying to this:\n$context Me: $prompt ? \n AImee: ",
          "max_tokens": maxTokens,
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
        return removeFirstNewline(generatedText);
      } else {
        throw Exception(
            "Failed to generate reply. Status code: ${response.statusCode}");
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return "Error generating reply:";
    }
  }

  Future<String> generateSummary(Message message, bool? french) async {
    //final discussion = getDiscussion(textsList);
    try {
      Response response = await Dio().post(
        "https://api.openai.com/v1/completions",
        data: {
          "prompt": french ?? false
              ? "Résume ce texte: ${message.text}"
              : "Please summarize this text: ${message.text}",
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
        String summary = "";
        if (message.isSender) {
          summary += french ?? false
              ? "Moi: ${removeEmptyLines(generatedText)} \n "
              : "Me: ${removeEmptyLines(generatedText)} \n ";
        } else {
          summary += "AImee: ${removeEmptyLines(generatedText)} \n ";
        }
        if (kDebugMode) {
          print("LOG: Summary: $summary");
        }
        return summary;
      } else {
        throw Exception(
            "Failed to generate summary. Status code: ${response.statusCode}");
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return "Error generating Summary";
    }
  }

  Future<String> generateTitle(String text, {bool? french}) async {
    bool inFrench = false;
    if (french != null) {
      if (french) {
        inFrench = true;
      }
    }
    try {
      Response response = await Dio().post(
        'https://api.openai.com/v1/completions',
        data: {
          "prompt": inFrench
              ? "En une phrase de moins de 5 mots, donne un titre à ce message, qui servira de sujet pour toute une conversation : $text ?"
              : "In a sentence of less than 5 words, give a title to this message, which will serve as a topic for an entire conversation : $text ?",
          "temperature": 0.8,
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

  String getDiscussion(List<Message> messagesList) {
    String discussion = "";

    for (Message message in messagesList) {
      if (message.isSender) {
        discussion += "ME: ${message.text} \n ";
      } else {
        discussion += "Pastor: ${message.text} \n ";
      }
    }
    return discussion;
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
