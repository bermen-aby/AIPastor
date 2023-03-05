import 'package:ai_pastor/models/chat_details.dart';
import 'package:ai_pastor/provider/selection_provider.dart';
import 'package:ai_pastor/services/ad_mob_services.dart';
import 'package:ai_pastor/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import '../../services/isar_services.dart';
import '../../services/theme_services.dart';
import '../../utils/dissmissible_widget.dart';
import '../../utils/translate.dart';
import '/pages/chat_page/chat_page.dart';

import '../../constants.dart';
import '../components/drawer_menu.dart';
import 'components/chat_card.dart';

class ChatsListPage extends StatefulWidget {
  const ChatsListPage({Key? key, required this.rateMyApp}) : super(key: key);
  final RateMyApp rateMyApp;

  @override
  State<ChatsListPage> createState() => _ChatsListPageState();
}

class _ChatsListPageState extends State<ChatsListPage> {
  final _advancedDrawerController = AdvancedDrawerController();
  final TextEditingController _titleController = TextEditingController();
  late SelectionProvider _selectionProvider;
  final IsarServices _isarServices = IsarServices();
  ChatDetails? _newChatDetails;
  BannerAd? _banner;
  bool adLoaded = false;

  @override
  void initState() {
    super.initState();
    _selectionProvider = Provider.of<SelectionProvider>(context, listen: false)
      ..init();
    WidgetsBinding.instance.addPostFrameCallback((_) => _createBannerAd());
  }

  @override
  void dispose() {
    _selectionProvider.dispose();
    _advancedDrawerController.dispose();
    // _selectionProvider.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _createBannerAd() {
    setState(() {
      adLoaded = true;
    });
    try {
      _banner = BannerAd(
        size: AdSize.fullBanner,
        adUnitId: AdMobServices.bannerAdUnitId,
        listener: AdMobServices.bannerAdListener,
        request: const AdRequest(),
      )..load().then((value) => setState(() {
            adLoaded = true;
          }));
    } catch (e) {
      debugPrint("LOG: error creating/loading banner: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdvancedDrawer(
      drawer: DrawerMenu(rateMyApp: widget.rateMyApp),
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      childDecoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Scaffold(
        appBar: buildAppBar(),
        body: body(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  rateMyApp: widget.rateMyApp,
                ),
              ),
            );
          },
          backgroundColor: kPrimaryColor,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        bottomNavigationBar: !adLoaded
            ? const SizedBox(
                height: 60,
              )
            : Container(
                margin: const EdgeInsets.only(bottom: 12),
                height: 60,
                child: AdWidget(ad: _banner!),
              ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[kSecondaryColor, kPrimaryColor])),
      ),
      leading: _selectionProvider.selectionMode
          ? IconButton(
              onPressed: () => setState(() {
                    _selectionProvider.selectionMode = false;
                    _selectionProvider.chatsDetails.clear();
                  }),
              icon: const Icon(Icons.arrow_back_rounded))
          : const SizedBox(),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_selectionProvider.selectionMode)
            Text(_selectionProvider.chatsDetails.length.toString()),
          const Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "Chats",
                style: TextStyle(
                  color: Colors.white,
                  // Provider.of<ThemeProvider>(context, listen: false)
                  //         .isDarkMode
                  //     ? Colors.white
                  //     : kPrimaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 23.5,
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        if (_selectionProvider.selectionMode &&
            _selectionProvider.chatsDetails.length == 1)
          IconButton(
              onPressed: () => changeTitle(), icon: const Icon(Icons.edit)),
        if (_selectionProvider.selectionMode)
          IconButton(
              onPressed: () => _deleteButton(), icon: const Icon(Icons.delete)),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            _advancedDrawerController.showDrawer();
          },
        ),
      ],
    );
  }

  Widget body() {
    return Container(
      decoration: ThemeServices().backgroundImage(context),
      child: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: _isarServices.getAllChatSmall(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.isEmpty) {
                    _empty();
                  } else {
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
                      itemBuilder: (context, ChatDetails chatDetails) {
                        if (_newChatDetails != null) {
                          if (_newChatDetails!.id == chatDetails.id) {
                            setState(() {
                              chatDetails = _newChatDetails!;
                            });
                          }
                        }
                        return DissmissibleWidget(
                          key: Key(chatDetails.id.toString()),
                          item: chatDetails,
                          onDismissed: (direction) async {
                            await _isarServices
                                .removeChatFromDetails(chatDetails);
                            setState(() {
                              snapshot.data!.remove(chatDetails);
                            });
                          },
                          child: ChatCard(
                            chat: chatDetails,
                            longPress: () {
                              setState(() {
                                _selectionProvider.selectionMode =
                                    !_selectionProvider.selectionMode;
                                if (_selectionProvider.selectionMode) {
                                  _selectionProvider
                                      .addOrRemoveChatDetails(chatDetails);
                                }
                              });
                            },
                            press: () {
                              if (_selectionProvider.selectionMode) {
                                _selectionProvider
                                    .addOrRemoveChatDetails(chatDetails);
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
                        );
                      },
                    );
                  }
                }

                return _empty();
              },
            ),
          ),
        ],
      ),
    );
  }

  _deleteButton() {
    Utils.showMessage(
      context,
      "Delete",
      "Are you sure you want to remove all these discussions?",
      "NO",
      () {
        Navigator.of(context).pop();
      },
      buttonText2: "YES",
      onPressed2: () {
        _selectionProvider.deleteChatsDetails();
        setState(() {});
        Navigator.of(context).pop();
      },
      isConfirmationDialog: true,
    );
  }

  void changeTitle() {
    _titleController.text = _selectionProvider.chatsDetails.first.title;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              t(context).changeTitle.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                //color: PremStyle.primary.shade900,
              ),
            ),
            content: TextField(
              controller: _titleController,
              maxLength: 40,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  //return
                  _popWindow();
                },
                child: Text(
                  t(context).cancel.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    //color: PremStyle.primary.shade900,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  //return
                  setState(() {
                    _selectionProvider.chatsDetails.first.title =
                        _titleController.text;
                  });

                  _selectionProvider.chatsDetails.first = await _isarServices
                      .saveDetails(_selectionProvider.chatsDetails.first);
                  setState(() {});

                  _popWindow();
                },
                child: Text(
                  t(context).ok.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    //color: PremStyle.primary.shade900,
                  ),
                ),
              )
            ],
          );
        });
  }

  Widget _empty() {
    return Center(
      child: Lottie.asset("assets/lottie/empty.json"),
    );
  }

  _popWindow() {
    Navigator.of(context).pop();
  }
}
