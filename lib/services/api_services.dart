import 'dart:io';

import 'package:ai_pastor/models/message.dart';
import 'package:ai_pastor/models/server_data.dart';
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
              ? "Vous êtes le Pasteur Jacob. Poursuivez la discussion en répondant à ce message et en ajoutant un verset biblique approprié si nécessaire.:\n$context MOI: $prompt ? \n PASTEUR: "
              : "You are Pastor Jacob. Continue the discussion by replying to this, and adding a revelant Bible verse if needed:\n$context ME: $prompt ? \n PASTOR: ",
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
      if (french ?? false) {
        return "Erreur de génération de réponse. Veuillez réessayer plus tard";
      }
      return "Error generating reply. Please try again later";
    }
  }

  Future<String> promptGPTTurbo(List<Map<String, String>> messages,
      {bool? french}) async {
    if (kDebugMode) {
      //print("LOG: context: $context");
    }
    // List<Map<String, String>> dataMessages = [];
    // if (french ?? false) {
    //   dataMessages.add({
    //     "role": "system",
    //     "content":
    //         "Vous êtes le Pasteur Jacob. Poursuivez la discussion en répondant à ce message et en ajoutant un verset biblique approprié si nécessaire",
    //   });
    // } else {
    //   dataMessages.add({
    //     "role": "system",
    //     "content":
    //         "You are Pastor Jacob. Continue the discussion by replying to this, and adding a revelant Bible verse if needed",
    //   });
    // }
    // messages?.forEach((element) {
    //   dataMessages.add({
    //     "role": element.isSender ? "user" : "assistant",
    //     "content": element.text,
    //   });
    // });
    try {
      Response response = await Dio().post(
        "https://api.openai.com/v1/chat/completions",
        data: {
          "model": "gpt-3.5-turbo",
          "messages": messages,
          //"max_tokens": maxTokens,
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
      if (french ?? false) {
        return "Erreur de génération de réponse. Veuillez réessayer plus tard";
      }
      return "Error generating reply. Please try again later";
    }
  }

  Future<String> generateSummary(Message message, bool? french) async {
    //final discussion = getDiscussion(textsList);
    // try {
    //   Response response = await Dio().post(
    //     "https://api.openai.com/v1/completions",
    //     data: {
    //       "prompt": french ?? false
    //           ? "Résume ce texte: ${message.text}"
    //           : "Please summarize this text: ${message.text}",
    //       "temperature": 0.5,
    //       "max_tokens": 100,
    //       "top_p": 1,
    //       "stop": "\n",
    //       "model": "text-curie-001",
    //     },
    //     options: Options(
    //       headers: {
    //         HttpHeaders.contentTypeHeader: "application/json",
    //         HttpHeaders.authorizationHeader: "Bearer $apiKey",
    //       },
    //     ),
    //   );
    //   if (response.statusCode == 200) {
    //     var generatedText = response.data['choices'][0]['text'];
    //     String summary = "";
    //     if (message.isSender) {
    //       summary += french ?? false
    //           ? "MOI: ${removeEmptyLines(generatedText)} \n "
    //           : "ME: ${removeEmptyLines(generatedText)} \n ";
    //     } else {
    //       summary += french ?? false
    //           ? "PASTEUR: ${removeEmptyLines(generatedText)} \n "
    //           : "PASTOR: ${removeEmptyLines(generatedText)} \n ";
    //     }
    //     if (kDebugMode) {
    //       print("LOG: Summary: $summary");
    //     }
    //     return summary;
    //   } else {
    //     throw Exception(
    //         "Failed to generate summary. Status code: ${response.statusCode}");
    //   }
    // } catch (e) {
    //   if (kDebugMode) {
    //     print(e);
    //   }
    //   return "Error generating Summary";
    // }

    String summary = "";
    String text = message.text;
    if (message.isSender) {
      summary += french ?? false ? "Moi: $text \n " : "Me: $text \n ";
    } else {
      summary += "Jacob: $text \n ";
    }

    return summary;
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
              ? "AI Pastor est une app de chat avec pasteur Jacob, assistant virtuel. En moins de 5 mots, donne un sujet à cette conversation dont le premier message de l'utilisateur est: $text ?"
              : "AI Pastor is a chat app with Pastor Jacob, virtual assistant. In less than 5 words, give a subject to this conversation whose first message from the user is: $text ?",
          "temperature": 0.3,
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
      if (french ?? false) {
        return "Nouvelle conversation";
      }
      return "New discussion";
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

  Future<ServerData> fetchPosts() async {
    try {
      final response = await Dio().get(
        baseUrl,
        options: Options(
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            HttpHeaders.authorizationHeader: "Token $jwtToken",
          },
        ),
      );

      if (response.data is List<dynamic>) {
        final List<dynamic> responseData = response.data;
        final List<ServerData> customPostTypes =
            responseData.map((json) => ServerData.fromJson(json)).toList();
        if (kDebugMode) {
          print(
              "LOG ServerData: ${customPostTypes.first.mandatoryUpdate} version ${customPostTypes.first.storeVersion} title ${customPostTypes.first.title} text ${customPostTypes.first.text}");
        }
        return customPostTypes.first;
      } else {
        if (kDebugMode) {
          print("LOG: fetchPosts response.data:${response.data}");
        }
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    if (kDebugMode) {
      print("LOG ServerData: empty");
    }
    return ServerData(mandatoryUpdate: false);
  }
}
