import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../constants.dart';
import '../../../models/chat_details.dart';

class ChatCard extends StatelessWidget {
  const ChatCard({
    Key? key,
    required this.chat,
    required this.press,
  }) : super(key: key);

  final ChatDetails chat;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: kDefaultPadding, vertical: kDefaultPadding * 0.75),
          child: Container(
            height: 85,
            //alignment: Alignment.centerLeft,
            child: Column(
              children: [
                Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Text(
                        chat.title,
                        maxLines: 3,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Opacity(
                        opacity: 0.90,
                        child: Text(
                          chat.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Opacity(
                    opacity: 0.64,
                    child: chat.date.year == DateTime.now().year
                        ? Text(DateFormat.MMMd().format(chat.date))
                        : Text(DateFormat.yMMMd().format(chat.date)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
