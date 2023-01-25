import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:new_version/new_version.dart';
import '/pages/chats_list_page/chats_list_page.dart';
import '/services/isar_services.dart';
import '../../models/chat_model.dart';
import '../../models/chat_details.dart';
import '../../variables.dart';
import 'package:rate_my_app/rate_my_app.dart';

import '../../models/message.dart';
import '../../services/api_services.dart';
import '../../constants.dart';
import '../../services/local_services.dart';
import '../components/drawer_menu.dart';

class ChatPage extends StatefulWidget {
  ChatPage({this.rateMyApp, this.chatDetails, super.key});

  final RateMyApp? rateMyApp;
  ChatDetails? chatDetails;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

enum TtsState { playing, stopped }

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _promptController = TextEditingController();
  String _generatedText = '';
  final String _title = 'New Discussion';
  final APIService _apiServices = APIService();
  bool _isListening = false; // Listening to the mic
  //bool _isPlaying = false; // Playing the Message
  bool _apiProcess = false;
  bool _autoPlay = true; // Automatically play AI responses
  //var ttsProdider;
  List<Message> messages = [];
  late FlutterTts _flutterTts;
  //String? _tts;
  TtsState _ttsState = TtsState.stopped;

  final _advancedDrawerController = AdvancedDrawerController();
  DateTime timeBackPressed = DateTime.now();
  bool connexion = false;

  final IsarServices _isarServices = IsarServices();
  late Chat? chat;
  //late ChatDetails chatDetails;

  @override
  void initState() {
    super.initState();
    initTts();
    initChat();
    //WidgetsBinding.instance.addPostFrameCallback((_) => firstVisit());
    WidgetsBinding.instance.addPostFrameCallback((_) => rateMyAppCheck());
    if (kDebugMode) {
      print('LOG: DATETIME NOW ${DateTime.now()}');
    }
  }

  @override
  void dispose() {
    _advancedDrawerController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  initTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.awaitSpeakCompletion(true);

    _flutterTts.setStartHandler(() {
      setState(() {
        debugPrint("Playing");
        _ttsState = TtsState.playing;
      });
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        debugPrint("Complete");
        _ttsState = TtsState.stopped;
      });
    });

    _flutterTts.setCancelHandler(() {
      setState(() {
        debugPrint("Cancel");
        _ttsState = TtsState.stopped;
      });
    });

    _flutterTts.setErrorHandler((message) {
      setState(() {
        debugPrint("Error: $message");
        _ttsState = TtsState.stopped;
      });
    });
  }

  initChat() async {
    if (widget.chatDetails != null) {
      chat = (await _isarServices.getChat(widget.chatDetails!))!;
      if (chat != null) {
        messages = await _isarServices.getChatMessages(chat!);
        print("LOG: Chat messages lenght ${chat!.messages.length}");
        print("LOG: Messages lenght ${messages.length}");
      }
    } else {
      messages.add(
        Message(
          text: "Hello, how can I help you?",
          date: DateTime.now(),
          isSender: false,
        ),
      );

      widget.chatDetails =
          ChatDetails(title: 'New Discussion', date: DateTime.now());
      chat = Chat()
        ..details.value = widget.chatDetails
        ..messages.addAll(messages);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      AdvancedDrawer(
        drawer: const DrawerMenu(),
        controller: _advancedDrawerController,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        childDecoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: WillPopScope(
          onWillPop: () async {
            final difference = DateTime.now().difference(timeBackPressed);
            final isExitWarning = difference >= const Duration(seconds: 2);
            timeBackPressed = DateTime.now();

            if (isExitWarning) {
              Fluttertoast.showToast(
                msg: "Press again to exit",
                fontSize: 18,
              );
              return false;
            } else {
              Fluttertoast.cancel();
              return true;
            }
          },
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              appBar: buildAppBar(),
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
                        alignment: !message.isSender
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              // color: MediaQuery.of(context).platformBrightness ==
                              //         Brightness.dark
                              //     ? Colors.white
                              //     : Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: kDefaultPadding * 0.75,
                                vertical: kDefaultPadding / 2,
                              ),
                              margin: message.isSender
                                  ? const EdgeInsets.fromLTRB(75, 0, 0, 0)
                                  : const EdgeInsets.fromLTRB(0, 0, 75, 0),
                              decoration: BoxDecoration(
                                color: kPrimaryColor
                                    .withOpacity(message.isSender ? 1 : 0.1),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                message.text,
                                style: TextStyle(
                                  color: message.isSender
                                      ? Colors.white
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .color,
                                ),
                              ),
                            ),
                            if (message.isSender)
                              const SizedBox(
                                height: 10,
                              ),
                            Row(
                              //crossAxisAlignment: CrossAxisAlignment.end,
                              //mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                if (message.isSender)
                                  const Expanded(child: SizedBox()),
                                Text(DateFormat.Hm().format(message.date)),
                                if (!message.isSender) playButton(message.text),
                              ],
                            )
                            // Row(
                            //   crossAxisAlignment: CrossAxisAlignment.end,
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     message.isSender
                            //         ? Text(DateFormat.Hm().format(message.date))
                            //         : const SizedBox(),
                            //     message.isSender
                            //         ? const SizedBox()
                            //         : Text(DateFormat.Hm().format(message.date)),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                    )),
                    Align(
                      alignment: Alignment.center,
                      child: Visibility(
                        visible: _apiProcess,
                        child: SizedBox(
                          height: 100,
                          width: 250,
                          child: Lottie.asset(
                            "assets/lottie/dots_loading.json",
                            repeat: true,
                          ),
                        ),
                      ),
                    ),
                    JelloIn(
                      child: SafeArea(
                        child: Row(
                          children: [
                            AvatarGlow(
                              animate: _isListening,
                              endRadius: _isListening ? 55 : 20,
                              child: TextButton(
                                  onPressed: () {
                                    if (!_apiProcess) {
                                      _toggleRecording();
                                    }
                                  },
                                  child: _isListening
                                      ? const Icon(
                                          Icons.stop_circle,
                                          color: Colors.red,
                                        )
                                      : const Icon(
                                          Icons.mic,
                                          color: kPrimaryColor,
                                        )),
                            ),
                            const SizedBox(width: kDefaultPadding / 3),
                            Expanded(
                              child: Container(
                                //color: Colors.grey.shade300,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: kDefaultPadding * 0.75,
                                ),
                                decoration: BoxDecoration(
                                  color: kPrimaryColor.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: TextField(
                                        maxLines: 8,
                                        minLines: 1,
                                        enabled: !_apiProcess,
                                        controller: _promptController,
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.all(12),
                                          border: InputBorder.none,
                                          hintText: 'Type message',
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        _sendText();
                                      },
                                      child: _apiProcess
                                          ? SizedBox(
                                              width: 40,
                                              height: 40,
                                              child: Lottie.asset(
                                                "assets/lottie/message_delivery.json",
                                                repeat: true,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.send,
                                              color: kPrimaryColor,
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
              // floatingActionButton: FloatingActionButton(
              //   backgroundColor: kPrimaryColor,
              //   onPressed: () {},
              //   child: AvatarGlow(
              //     animate: _isListening,
              //     endRadius: _isListening ? 75 : 20,
              //     child: TextButton(
              //         onPressed: () {
              //           _toggleRecording();
              //         },
              //         child: _isListening
              //             ? const Icon(
              //                 Icons.stop_circle,
              //                 color: Colors.red,
              //               )
              //             : const Icon(
              //                 Icons.mic,
              //                 color: Colors.white,
              //               )),
              //   ),
              // ),
              // floatingActionButtonLocation: FloatingActionButtonLocation.miniEndDocked,
            ),
          ),
        ),
      ),
      Visibility(
        visible: isPopupActive,
        child: const SizedBox(),
      )
    ]);
  }

  AppBar buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,

      title: Row(
        //crossAxisAlignment: CrossAxisAlignment.center,
        //mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BounceInDown(
            child: const CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage("assets/images/pastor.png"),
            ),
          ),
          const SizedBox(width: kDefaultPadding * 0.50),
          Expanded(
            child: InkWell(
              onTap: () {},
              child: TextButton(
                onPressed: () {},
                child: FadeIn(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Pastor Jacob", // AI Pastor
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      Text(
                        widget.chatDetails?.title ?? '',
                        //"Active 3m ago",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      leading: IconButton(
        icon: const Icon(Icons.history),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatsListPage(),
            ),
          );
        },
      ), //BackButton(),
      actions: [
        IconButton(
          icon: _autoPlay
              ? const Icon(Icons.volume_up)
              : const Icon(Icons.volume_off),
          tooltip: "Turn off the voice",
          onPressed: () {
            setState(() {
              _autoPlay = !_autoPlay;
            });
          },
        ),
        IconButton(
          icon: ValueListenableBuilder(
              valueListenable: _advancedDrawerController,
              builder: (_, value, __) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    value.visible ? Icons.clear : Icons.settings,
                    key: ValueKey<bool>(value.visible),
                  ),
                );
              },
              child: const Icon(Icons.settings)),
          onPressed: () {
            _advancedDrawerController.showDrawer();
          },
          tooltip: "Open the settings",
        ),
        const SizedBox(width: kDefaultPadding / 2),
      ],
    );
  }

  Widget playButton(String message) {
    if (_ttsState == TtsState.stopped) {
      return TextButton(
        onPressed: () async {
          if (!_apiProcess) {
            await speak(message);
          }
        },
        child: const Icon(
          Icons.play_circle,
          color: kPrimaryColor,
          size: 32,
        ),
      );
    } else {
      return TextButton(
        onPressed: stop,
        child: const Icon(
          Icons.stop_circle,
          color: kPrimaryColor,
        ),
      );
    }
  }

  Future speak(String message) async {
    await _flutterTts.setVolume(1);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(0.61);
    await _flutterTts.setLanguage("en-US");
    final voices = await _flutterTts.getVoices;
    if (kDebugMode) {
      print("LOG AVAILABLE VOICES : $voices");
    }

    if (messages.isNotEmpty) {
      await _flutterTts.speak(message).then((value) {});
    }
  }

  Future stop() async {
    var result = await _flutterTts.stop();
    if (result == 1) {
      setState(() {
        _ttsState = TtsState.stopped;
      });
    }
  }

  _toggleRecording() {
    _apiServices.toggleRecording(
      onResult: (text) => setState(
        () {
          _promptController.text = text;
          if (text.isNotEmpty) {
            //_sendText();
          }
        },
      ),
      onListening: (value) {
        setState(() => _isListening = value);
      },
    );
  }

  void rateMyAppCheck() {
    Future.delayed(const Duration(seconds: 15), () {
      if (widget.rateMyApp != null) {
        if (widget.rateMyApp!.shouldOpenDialog) {
          widget.rateMyApp!.showStarRateDialog(
            context,
            title: "AppLocalizations.of(context)!.rateTitle",
            message: "AppLocalizations.of(context)!.rateReview",
            starRatingOptions: const StarRatingOptions(initialRating: 4),
            actionsBuilder: actionsBuilder,
          );
        }
      }
    });
  }

  List<Widget> actionsBuilder(BuildContext context, double? stars) =>
      stars == null
          ? [_buildCancelButton()]
          : [_buildOkButton(stars), _buildLaterButton(), _buildCancelButton()];

  Widget _buildOkButton(double? stars) => TextButton(
        onPressed: () async {
          if (stars != null) {
            if (stars >= 4) {
              widget.rateMyApp!.launchStore();
            }
            const event = RateMyAppEventType.rateButtonPressed;
            await widget.rateMyApp!.callEvent(event);
            Fluttertoast.showToast(
              msg: "AppLocalizations.of(context)!.thanksForReview",
            );
            _popWindow();
          }
        },
        child: const Text("AppLocalizations.of(context)!.okText"),
      );

  Widget _buildLaterButton() => TextButton(
        onPressed: () async {
          const event = RateMyAppEventType.laterButtonPressed;
          await widget.rateMyApp!.callEvent(event);

          _popWindow();
        },
        child: const Text("AppLocalizations.of(context)!.later"),
      );

  Widget _buildCancelButton() => TextButton(
        onPressed: () async {
          const event = RateMyAppEventType.noButtonPressed;
          await widget.rateMyApp!.callEvent(event);
          _popWindow();
        },
        child: const Text("AppLocalizations.of(context)!.cancel"),
      );

  // RateMyAppNoButton(
  //       widget.rateMyApp!,
  //       text: AppLocalizations.of(context)!.cancel,
  //     );

  Future<bool> checkConnection() async {
    connexion = await LocalServices.hasInternet();
    return true;
  }

  Future<bool> _checkVersion() async {
    final newVersion = NewVersion(
      androidId: "com.premgroup.prem_market", //"com.snapchat.android",
      iOSId: "com.premmiumgroup.premMarket",
    );
    try {
      final status = await newVersion.getVersionStatus().then((value) {
        Future.delayed(const Duration(seconds: 10), () {
          if (value?.localVersion != value?.storeVersion) {
            newVersion.showUpdateDialog(
              context: context,
              versionStatus: value!,
              dialogText: "AppLocalizations.of(context)!.updateText",
              dialogTitle: "AppLocalizations.of(context)!.updateNotice",
              dismissButtonText:
                  "AppLocalizations.of(context)!.later.toUpperCase()",
              updateButtonText:
                  "AppLocalizations.of(context)!.update.toUpperCase()",
            );
          }
        });
      });
      if (kDebugMode) {
        print(
          "APP version ${status?.localVersion} - Store version ${status?.storeVersion}",
        );
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }

    maj = false;
    return true;
  }

  Future<void> firstVisit() async {
    if (await LocalServices.firstVisit()) {
      Timer(const Duration(minutes: 1), () {
        setState(() {
          isPopupActive = true;
        });
      });
    }
  }

  void _sendText() async {
    final message = Message(
        text: _promptController.text, date: DateTime.now(), isSender: true);
    setState(() {
      messages.add(message);
      _promptController.clear();
      _apiProcess = true;
    });

    widget.chatDetails!
      ..date = DateTime.now()
      ..lastMessage = message.text;
    if (messages.length == 2) {
      widget.chatDetails!.title =
          await _apiServices.generateTitle(message.text);
    }

    chat!.details.value = widget.chatDetails;
    chat!.messages.add(message);

    _isarServices.saveChat(chat!, message);
    _generatedText = await _apiServices.generateReply(message.text);
    final messageResponse =
        Message(text: _generatedText, date: DateTime.now(), isSender: false);
    setState(() {
      messages.add(messageResponse);
      _apiProcess = false;
    });
    widget.chatDetails!
      ..date = DateTime.now()
      ..lastMessage = _generatedText;
    chat!.messages.add(messageResponse);
    _isarServices.saveChat(chat!, messageResponse);
    if (kDebugMode) {
      print("New title is: ${widget.chatDetails?.title}");
    }
  }

  _popWindow() {
    Navigator.of(context).pop();
  }
}
