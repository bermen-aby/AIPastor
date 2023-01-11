import 'package:dio/dio.dart';

String apiKey = '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';
String model = 'text-davinci-003';
//String prompt = 'The quick brown fox jumps over the lazy dog.';
int maxTokens = 512;
String stop = '.';

class APIService {
  askGP3(String prompt) async {
    Response response = await Dio().post(
      'https://api.openai.com/v1/completions',
      data: {
        'model': model,
        'prompt':
            "Respond to this question as a pastor named David. Add some relevant bible verses if possible: $prompt",
        'max_tokens': maxTokens,
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
}
