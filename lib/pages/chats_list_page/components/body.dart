import 'package:flutter/material.dart';
import 'package:newapp/models/chat_small_model.dart';
import 'package:newapp/pages/chat_page/chat_page.dart';
import 'package:newapp/services/isar_services.dart';

import '../../../components/filled_outline_button.dart';
import '../../../constants.dart';
import 'chat_card.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final IsarServices _isarServices = IsarServices();

  late List<ChatSmall?> chats;

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    chats = await _isarServices.getAllChatSmall();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(
              kDefaultPadding, 0, kDefaultPadding, kDefaultPadding),
          color: kPrimaryColor,
          child: Row(
            children: [
              FillOutlineButton(press: () {}, text: "Recent Message"),
              const SizedBox(width: kDefaultPadding),
              FillOutlineButton(
                press: () {},
                text: "Active",
                isFilled: false,
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder(
            future: _isarServices.getAllChatSmall(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data != null) {
                  if (snapshot.data!.isNotEmpty) {
                    return ListView.builder(
                      itemCount: chats.length,
                      itemBuilder: (context, index) => (chats.isNotEmpty)
                          ? ChatCard(
                              chat: chats[index]!,
                              press: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ChatPage(),
                                ),
                              ),
                            )
                          : const Text("test"),
                    );
                  }
                }
              }
              return Text("No Chat yet!");
            },
          ),
        ),
      ],
    );
  }
}
