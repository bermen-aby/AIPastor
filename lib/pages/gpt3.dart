import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:newapp/models/message.dart';
import 'package:newapp/pages/tts_player.dart';
import 'package:newapp/services/apiServices.dart';
import 'package:provider/provider.dart';

class Gpt3Page extends StatefulWidget {
  @override
  _Gpt3PageState createState() => _Gpt3PageState();
}

class _Gpt3PageState extends State<Gpt3Page> {
  final TextEditingController _promptController = TextEditingController();
  String _generatedText = '';
  APIService _apiServices = APIService();
  bool _playing = false;
  //var ttsProdider;
  List<Message> messages = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

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
            Expanded(
                child: GroupedListView<Message, DateTime>(
              padding: const EdgeInsets.all(8),
              reverse: true,
              order: GroupedListOrder.DESC,
              useStickyGroupSeparators: true,
              floatingHeader: true,
              elements: messages,
              groupBy: (message) => DateTime(
                message.date.year,
                message.date.month,
                message.date.day,
              ),
              groupHeaderBuilder: (Message message) => SizedBox(
                height: 40,
                child: Center(
                  child: Card(
                    color: Theme.of(context).primaryColor,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        DateFormat.yMMMd().format(message.date),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              itemBuilder: (context, Message message) => Align(
                alignment: message.isSentByMe
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(message.text),
                  ),
                ),
              ),
            )),
            Container(
              color: Colors.grey.shade300,
              child: TextField(
                controller: _promptController,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(12),
                  hintText: 'Type your Message..',
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final message = Message(
                        text: _promptController.text,
                        date: DateTime.now(),
                        isSentByMe: true);
                    setState(() {
                      messages.add(message);
                    });
                    _generatedText =
                        await _apiServices.askGP3(_promptController.text);
                    final messageResponse = Message(
                        text: _generatedText,
                        date: DateTime.now(),
                        isSentByMe: false);
                    setState(() {
                      messages.add(messageResponse);
                    });
                  },
                  child: const Text('Generate Text'),
                ),
                IconButton(
                    onPressed: (() {
                      _playing = !_playing;
                      _playTTS();
                    }),
                    icon: _playing
                        ? const Icon(
                            Icons.play_arrow,
                            color: Colors.black,
                          )
                        : const Icon(
                            Icons.stop_circle,
                            color: Colors.black,
                          )),
              ],
            ),
            // const SizedBox(height: 16.0),
            // Flexible(child: Text(_generatedText)),
          ],
        ),
      ),
    );
  }

  _playTTS() {
    final ttsProdider = Provider.of<TTSPlayerProvider>(context, listen: false);
    ttsProdider.initializeTts();
    ttsProdider.text = _generatedText;
    _playing ? ttsProdider.stop() : ttsProdider.speak();
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
