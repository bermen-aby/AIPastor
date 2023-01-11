import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:newapp/services/apiServices.dart';

class Gpt3Page extends StatefulWidget {
  @override
  _Gpt3PageState createState() => _Gpt3PageState();
}

class _Gpt3PageState extends State<Gpt3Page> {
  final TextEditingController _promptController = TextEditingController();
  String _generatedText = '';
  APIService _apiServices = APIService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPT-3'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _promptController,
              decoration: const InputDecoration(
                hintText: 'Enter prompt',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                _generatedText =
                    await _apiServices.askGP3(_promptController.text);
                setState(() {});
              },
              child: const Text('Generate Text'),
            ),
            const SizedBox(height: 16.0),
            Text(_generatedText),
          ],
        ),
      ),
    );
  }
}

// void _generateText() async {
//   String apiKey = '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';
//   String model = 'text-davinci-003';
//   String prompt = _promptController.text;
//   int temperature = 0;
//   int maxTokens = 256;
//   String stop = '.';

//   Dio dio = Dio();
//   print('request sent');
//   Response response = await dio.post(
//     'https://api.openai.com/v1/text_completions/',
//     data: {
//       'model': model,
//       'prompt': prompt + stop,
//       'max_tokens': maxTokens,
//       'temperature': temperature,
//       'stop': stop,
//     },
//     options: Options(
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $apiKey',
//       },
//     ),
//   );

//   if (response.statusCode == 200) {
//     print('response success');
//     setState(() {
//       _generatedText = response.data['choices'][0]['text'];
//     });
//   } else {
//     setState(() {
//       _generatedText = response.statusCode.toString();
//     });
//   }
// }
