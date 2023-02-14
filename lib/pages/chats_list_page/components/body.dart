import 'package:ai_pastor/provider/selection_provider.dart';
import 'package:ai_pastor/utils/dissmissible_widget.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';

import '../../../models/chat_details.dart';
import '../../../services/isar_services.dart';
import '../../chat_page/chat_page.dart';
import 'chat_card.dart';

class Body extends StatefulWidget {
  const Body({super.key, required this.rateMyApp});
  final RateMyApp rateMyApp;
  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final IsarServices _isarServices = IsarServices();
  late SelectionProvider _selectionProvider;

  @override
  void initState() {
    super.initState();
    _selectionProvider = Provider.of<SelectionProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                  itemBuilder: (context, ChatDetails chatDetails) =>
                      DissmissibleWidget(
                    key: Key(chatDetails.id.toString()),
                    item: chatDetails,
                    onDismissed: (direction) async {
                      await _isarServices.removeChatFromDetails(chatDetails);
                      setState(() {
                        snapshot.data!.remove(chatDetails);
                      });
                    },
                    child: Stack(
                      children: [
                        ChatCard(
                          chat: chatDetails,
                          longPress: () {
                            setState(() {
                              _selectionProvider.selectionMode =
                                  !_selectionProvider.selectionMode;
                            });
                            if (_selectionProvider.selectionMode) {
                              if (_selectionProvider.chatsDetails
                                  .contains(chatDetails)) {
                                _selectionProvider
                                    .removeChatsDetails(chatDetails);
                              } else {
                                _selectionProvider.addChatsDetails(chatDetails);
                              }
                            }
                            setState(() {});
                          },
                          press: () {
                            if (_selectionProvider.selectionMode) {
                              if (_selectionProvider.chatsDetails
                                  .contains(chatDetails)) {
                                _selectionProvider
                                    .removeChatsDetails(chatDetails);
                              } else {
                                _selectionProvider.addChatsDetails(chatDetails);
                              }
                              setState(() {});
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                    chatDetails: chatDetails,
                                    rateMyApp: widget.rateMyApp,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        if (_selectionProvider.selectionMode &&
                            _selectionProvider.chatsDetails
                                .contains(chatDetails))
                          Container(
                            color: Colors.blue.withOpacity(0.5),
                          ),
                      ],
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
