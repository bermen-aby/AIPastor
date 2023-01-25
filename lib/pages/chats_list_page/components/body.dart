import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';

import '../../../components/filled_outline_button.dart';
import '../../../constants.dart';
import '../../../models/chat_model.dart';
import '../../../models/chat_details.dart';
import '../../../services/isar_services.dart';
import '../../chat_page/chat_page.dart';
import 'chat_card.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final IsarServices _isarServices = IsarServices();

  @override
  void initState() {
    super.initState();
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
                return GroupedListView<ChatDetails, DateTime>(
                  padding: const EdgeInsets.all(8),
                  reverse: true,
                  order: GroupedListOrder.ASC,
                  useStickyGroupSeparators: true,
                  shrinkWrap: true,
                  groupHeaderBuilder: (element) => const SizedBox(),
                  elements: snapshot.data as List<ChatDetails>,
                  groupBy: (chatSmall) => DateTime(
                    chatSmall.date.year,
                    chatSmall.date.month,
                    chatSmall.date.day,
                  ),
                  itemBuilder: (context, ChatDetails chatSmall) => ChatCard(
                    chat: chatSmall,
                    press: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          chatDetails: chatSmall,
                        ),
                      ),
                    ),
                  ),
                );
              }

              return const Text("No Chat yet!");
            },
          ),
        ),
      ],
    );
  }
}
