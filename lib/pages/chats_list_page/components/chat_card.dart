import 'package:ai_pastor/utils/utils.dart';
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
        shadowColor: kPrimaryColor,
        color: kSecondaryColor.withOpacity(0.25),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: kDefaultPadding, vertical: kDefaultPadding * 0.75),
          child: SizedBox(
            height: 85,
            //alignment: Alignment.centerLeft,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    chat.title,
                    maxLines: 1,
                    style: //Theme.of(context).textTheme.headlineSmall,
                        const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Opacity(
                  opacity: 0.90,
                  child: Text(
                    Utils().removeEmptyLines(chat.lastMessage),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
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
