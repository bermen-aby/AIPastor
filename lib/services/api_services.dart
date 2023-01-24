import 'package:dio/dio.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:speech_to_text/speech_to_text.dart';

String apiKey = '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';
String model = 'text-davinci-003';
//String prompt = 'The quick brown fox jumps over the lazy dog.';
int maxTokens = 512;
String stop = '.';

class APIService {
  final _speech = SpeechToText();

  askGP3(String prompt, {String? context}) async {
    Response response = await Dio().post(
      'https://api.openai.com/v1/completions',
      data: {
        'model': model,
        'prompt': context != null
            ? "You are Pastor Jacob, here to help with empathy. Continue this conversation, adding relevant Bible verses if possible: $context. Me: $prompt. You:"
            : "As a christian: $prompt",
        'max_tokens': maxTokens,
        'temperature': 0.3,
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
      ),
    );
    if (response.statusCode == 200) {
      print("LOG ${response.data}");
      var generatedText = response.data['choices'][0]['text'];
      print("LOG $generatedText");
      return generatedText;
    }

    return response.statusCode.toString();
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
