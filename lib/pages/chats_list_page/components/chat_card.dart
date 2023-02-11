import 'package:ai_pastor/provider/selection_provider.dart';
import 'package:ai_pastor/provider/theme_provider.dart';
import 'package:ai_pastor/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../models/chat_details.dart';

class ChatCard extends StatefulWidget {
  const ChatCard({
    Key? key,
    required this.chat,
    required this.press,
    required this.longPress,
  }) : super(key: key);

  final ChatDetails chat;
  final VoidCallback press;
  final VoidCallback longPress;

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  final titleLight = const TextStyle(
    color: kPrimaryColor,
    fontWeight: FontWeight.w800,
    overflow: TextOverflow.ellipsis,
    fontSize: 17,
  );
  final titleDark = const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w800,
    overflow: TextOverflow.ellipsis,
    fontSize: 17,
  );
  final lastMsgLight = const TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.w500,
    fontSize: 14,
  );
  final lastMsgDark = const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w500,
    fontSize: 14,
  );
  final dateLight = const TextStyle(
    color: Colors.black,
    //fontWeight: FontWeight.w500,
    //fontSize: 22,
  );
  final dateDark = const TextStyle(
    color: Colors.white,
    // fontWeight: FontWeight.w500,
    // fontSize: 22,
  );
  late SelectionProvider _selectionProvider;
  @override
  void initState() {
    super.initState();
    _selectionProvider = Provider.of<SelectionProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false);
    final title = theme.isDarkMode ? titleDark : titleLight;
    final lastMsg = theme.isDarkMode ? lastMsgDark : lastMsgLight;
    final timeTxt = theme.isDarkMode ? dateDark : dateLight;
    return GestureDetector(
      onTap: widget.press,
      onLongPress: widget.longPress,
      child: Card(
        shadowColor: kPrimaryColor,
        color: _selectionProvider.containsChatDetails(widget.chat)
            ? Colors.white
            : kSecondaryColor.withOpacity(0.25),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: kDefaultPadding, vertical: kDefaultPadding * 0.75),
          child: SizedBox(
            height: 100,
            //alignment: Alignment.centerLeft,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    widget.chat.title,
                    maxLines: 1,
                    style: _selectionProvider.containsChatDetails(widget.chat)
                        ? const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                            color: kPrimaryColor)
                        : title,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Opacity(
                  opacity: 0.90,
                  child: Text(Utils().removeEmptyLines(widget.chat.lastMessage),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _selectionProvider.containsChatDetails(widget.chat)
                          ? const TextStyle(color: kPrimaryColor)
                          : lastMsg),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Opacity(
                    opacity: 0.64,
                    child: Text(
                      widget.chat.date.year == DateTime.now().year
                          ? DateFormat.MMMd().format(widget.chat.date)
                          : DateFormat.yMMMd().format(widget.chat.date),
                      style: _selectionProvider.containsChatDetails(widget.chat)
                          ? const TextStyle(color: kPrimaryColor)
                          : timeTxt,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
