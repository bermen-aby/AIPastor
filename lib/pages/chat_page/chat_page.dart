import 'dart:async';

import 'package:ai_pastor/pages/onboarding/slides/donation.dart';
import 'package:ai_pastor/provider/selection_provider.dart';
import 'package:ai_pastor/provider/theme_provider.dart';
import 'package:ai_pastor/utils/translate.dart';
import 'package:animate_do/animate_do.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:camera/camera.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:new_version/new_version.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/menu_item.dart';
import '../../utils/utils.dart';
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

// ignore: must_be_immutable
class ChatPage extends StatefulWidget {
  ChatPage({required this.rateMyApp, this.chatDetails, super.key});

  final RateMyApp rateMyApp;
  ChatDetails? chatDetails;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

enum TtsState { playing, stopped }

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  String _generatedText = '';
  final APIService _apiServices = APIService();
  bool _isListening = false; // Listening to the mic
  bool _apiProcess = false;
  bool _autoPlay = true; // Automatically play AI responses
  List<Message> messages = [];
  late FlutterTts _flutterTts;
  TtsState _ttsState = TtsState.stopped;

  bool cameraGranted = false;

  final _advancedDrawerController = AdvancedDrawerController();
  DateTime timeBackPressed = DateTime.now();
  bool connexion = false;

  final IsarServices _isarServices = IsarServices();
  late Chat? chat;
  late SelectionProvider _selectionProvider;

  MenuItem itemCopy = MenuItem(text: 'Copy', icon: Icons.copy);
  MenuItem itemShare = MenuItem(text: 'Share', icon: Icons.share);

  List<MenuItem> itemList = [];

  CameraController? _cameraController;

  @override
  void initState() {
    super.initState();
    initTts();

    _selectionProvider = Provider.of<SelectionProvider>(context, listen: false);
    _selectionProvider.init();
    if (maj) {
      _checkVersion();
    }
    initChat();
    //WidgetsBinding.instance.addPostFrameCallback((_) => firstVisit());

    WidgetsBinding.instance.addPostFrameCallback((_) => rateMyAppCheck());
    WidgetsBinding.instance.addObserver(this);
    if (kDebugMode) {
      print('LOG: DATETIME NOW ${DateTime.now()}');
    }
  }

  @override
  void dispose() {
    _advancedDrawerController.dispose();
    _flutterTts.stop();
    WidgetsBinding.instance.removeObserver(this);
    _stopCamera();
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
    cameraGranted = await LocalServices.requestCameraPermission();
    _autoPlay = await LocalServices.getAutoPlay();
    if (widget.chatDetails != null) {
      chat = (await _isarServices.getChat(widget.chatDetails!))!;
      if (chat != null) {
        messages = await _isarServices.getChatMessages(chat!);
        if (kDebugMode) {
          print("LOG: Chat messages lenght ${chat!.messages.length}");
          print("LOG: Messages lenght ${messages.length}");
        }
      }
    } else {
      messages.add(
        Message(
          text: t(context).hello,
          date: DateTime.now(),
          isSender: false,
        ),
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => initChatWithContext());
    setState(() {});
  }

  initChatWithContext() async {
    widget.chatDetails =
        ChatDetails(title: t(context).newDiscussion, date: DateTime.now());
    chat = Chat()
      ..details.value = widget.chatDetails
      ..messages.addAll(messages);

    itemCopy.text = t(context).copy;
    itemShare.text = t(context).share;
    itemList.addAll([itemCopy, itemShare]);
    setState(() {});
    int launchCount = await LocalServices.getLaunchCount();
    if (launchCount % 1 == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Donation(slideNumber: 3, donatePageOnly: true),
        ),
      );
    }
    // final theme = Provider.of<ThemeProvider>(context, listen: false);
    // SystemChrome.setSystemUIOverlayStyle(
    //     theme.isDarkMode ? darkOverlayStyle : lightOverlayStyle);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      AdvancedDrawer(
        drawer: DrawerMenu(
          rateMyApp: widget.rateMyApp,
        ),
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
                msg: t(context).pressToExit,
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
              //backgroundColor: kContentColorLightTheme,
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
                                  DateFormat.yMMMd()
                                      .format(message.date)
                                      .toUpperCase(),
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
                          child: GestureDetector(
                            onLongPress: () {
                              setState(() {
                                _selectionProvider.selectionMode =
                                    !_selectionProvider.selectionMode;
                                if (_selectionProvider.selectionMode) {
                                  _selectionProvider
                                      .addOrRemoveMessage(message);
                                }
                              });
                            },
                            onTap: () {
                              if (_selectionProvider.selectionMode) {
                                _selectionProvider.addOrRemoveMessage(message);
                                setState(() {});
                              } else {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => ChatPage(
                                //       chatDetails: chatDetails,
                                //     ),
                                //   ),
                                // );
                              }
                            },
                            child: _messageCard(message),
                          ),
                        ),
                      ),
                    ),
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
                      child: FutureBuilder(
                          future: LocalServices.hasInternet(),
                          builder: (context, AsyncSnapshot<bool> hasInternet) {
                            if (hasInternet.hasData) {
                              if (hasInternet.data!) {
                                return SafeArea(
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
                                      const SizedBox(
                                          width: kDefaultPadding / 3),
                                      Expanded(
                                        child: Container(
                                          //color: Colors.grey.shade300,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: kDefaultPadding * 0.40,
                                          ),
                                          decoration: BoxDecoration(
                                            //color: kPrimaryColor.withOpacity(0.05),
                                            borderRadius:
                                                BorderRadius.circular(40),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: TextField(
                                                  maxLines: 8,
                                                  minLines: 1,
                                                  enabled: !_apiProcess,
                                                  controller: _promptController,
                                                  decoration:
                                                      const InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.all(12),
                                                    //border: InputBorder.none,
                                                    hintText: 'Type message',
                                                  ),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  if (await LocalServices
                                                      .hasInternet()) {
                                                    _sendText();
                                                  }
                                                  setState(() {});
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
                                );
                              }
                            }
                            return noNet();
                          }),
                    ),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
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
      title: _selectionProvider.selectionMode
          ? Text(_selectionProvider.messages.length.toString())
          : InkWell(
              onTap: () {
                changeTitle();
              },
              child: Row(
                children: [
                  BounceInDown(
                    child: const CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage("assets/images/ai.png"),
                    ),
                  ),
                  const SizedBox(width: kDefaultPadding * 0.50),
                  Expanded(
                    child: FadeIn(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t(context).pastorJacob, // AImee
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white),
                          ),
                          Text(
                            widget.chatDetails?.title ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
      leading: _selectionProvider.selectionMode
          ? IconButton(
              onPressed: () => setState(() {
                    _selectionProvider.selectionMode = false;
                    _selectionProvider.messages.clear();
                  }),
              icon: const Icon(Icons.arrow_back_rounded))
          : IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChatsListPage(rateMyApp: widget.rateMyApp),
                  ),
                );
              },
            ),
      actions: [
        // if (_selectionProvider.selectionMode)
        //   IconButton(
        //     tooltip: t(context).deleteMessages,
        //     onPressed: () => _deleteButton(),
        //     icon: const Icon(Icons.delete),
        //   ),
        if (_selectionProvider.selectionMode &&
            _selectionProvider.messages.length == 1)
          PopupMenuButton<MenuItem>(
            onSelected: (item) => _shareItemSelected(context, item),
            itemBuilder: (context) =>
                [...itemList.map(_buildShareItems).toList()],
            child: const Icon(Icons.ios_share),
          ),
        if (!_selectionProvider.selectionMode)
          IconButton(
            icon: const Icon(Icons.scanner),
            tooltip: t(context).voiceOff,
            onPressed: () async {
              cameraGranted = await LocalServices.requestCameraPermission();
              final cameras = await availableCameras().then(
                (value) {
                  _initCameraController(value);
                  return CameraPreview(_cameraController!);
                },
              );

              setState(() {});
            },
          ),
        IconButton(
          icon: _autoPlay
              ? const Icon(Icons.volume_up)
              : const Icon(Icons.volume_off),
          tooltip: t(context).voiceOff,
          onPressed: () {
            setState(() {
              _autoPlay = !_autoPlay;
              LocalServices.setAutoPlay(_autoPlay);
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
                    value.visible ? Icons.clear : Icons.more_vert,
                    key: ValueKey<bool>(value.visible),
                  ),
                );
              },
              child: const Icon(Icons.more_vert)),
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
    Locale _locale = Localizations.localeOf(context);
    String _languageCode = _locale.languageCode;
    print(_locale.languageCode);
    if (_languageCode == "fr") {
      await _flutterTts.setLanguage("fr-FR");
    } else {
      await _flutterTts.setLanguage("en-US");
    }

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
      if (widget.rateMyApp.shouldOpenDialog) {
        widget.rateMyApp.showStarRateDialog(
          context,
          title: t(context).rateTheApp,
          message: t(context).rateAppMessage,
          starRatingOptions: const StarRatingOptions(initialRating: 4),
          actionsBuilder: actionsBuilder,
        );
      }
    });
  }

  List<Widget> actionsBuilder(BuildContext context, double? stars) =>
      stars == null
          ? [_buildCancelButton()]
          : [
              _buildCancelButton(),
              _buildLaterButton(),
              _buildOkButton(stars),
            ];

  Widget _buildOkButton(double? stars) => TextButton(
        onPressed: () async {
          if (stars != null) {
            if (stars >= 4) {
              widget.rateMyApp.launchStore();
            }
            const event = RateMyAppEventType.rateButtonPressed;
            await widget.rateMyApp.callEvent(event);
            Fluttertoast.showToast(
              msg: t(context).thanksForRating,
            );
            _popWindow();
          }
        },
        child: Text(
          t(context).ok.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );

  Widget _buildLaterButton() => TextButton(
        onPressed: () async {
          const event = RateMyAppEventType.laterButtonPressed;
          await widget.rateMyApp.callEvent(event);

          _popWindow();
        },
        child: Text(
          t(context).later.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );

  Widget _buildCancelButton() => TextButton(
        onPressed: () async {
          const event = RateMyAppEventType.noButtonPressed;
          await widget.rateMyApp.callEvent(event);
          _popWindow();
        },
        child: Text(
          t(context).cancel.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );

  Future<bool> checkConnection() async {
    connexion = await LocalServices.hasInternet();
    setState(() {});
    return true;
  }

  Future<bool> _checkVersion() async {
    final newVersion = NewVersion(
      androidId: playStoreId, //"com.snapchat.android",
      iOSId: appleStoreId,
    );
    try {
      final status = await newVersion.getVersionStatus().then((value) {
        Future.delayed(const Duration(seconds: 10), () {
          if (value?.localVersion != value?.storeVersion) {
            newVersion.showUpdateDialog(
              context: context,
              versionStatus: value!,
              dialogText: t(context).updateText,
              dialogTitle: t(context).updateAvailable,
              dismissButtonText: t(context).later,
              updateButtonText: t(context).update,
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
    if (widget.chatDetails == null) {
      widget.chatDetails =
          ChatDetails(title: t(context).newDiscussion, date: DateTime.now());
    }
    widget.chatDetails!
      ..date = DateTime.now()
      ..lastMessage = message.text;
    if (messages.length == 2) {
      Locale _locale = Localizations.localeOf(context);
      String _languageCode = _locale.languageCode;
      bool french = false;
      print(_locale.languageCode);
      if (_languageCode == "fr") {
        french = true;
      }
      widget.chatDetails!.title =
          await _apiServices.generateTitle(message.text, french: french);
    }

    chat!.details.value = widget.chatDetails;
    //chat!.messages.add(message);
    debugPrint(
        "LOG: chat.details.value.lastMessage ${chat?.details.value?.lastMessage}");
    debugPrint("LOG: chat.details.value.id ${chat?.details.value?.id}");

    chat!.summary += await _apiServices.generateSummary(message);
    chat = await _isarServices.saveChat(chat!, message);
    _generatedText =
        await _apiServices.generateReply(message.text, context: chat?.summary);
    final messageResponse =
        Message(text: _generatedText, date: DateTime.now(), isSender: false);
    setState(() {
      messages.add(messageResponse);
      _apiProcess = false;
    });
    if (_autoPlay &&
        _ttsState == TtsState.stopped &&
        !messageResponse.text.contains("Error generating")) {
      speak(messageResponse.text);
    }
    widget.chatDetails!
      ..date = DateTime.now()
      ..lastMessage = _generatedText;
    //chat!.messages.add(messageResponse);
    //chat = await _isarServices.saveChat(chat!, messageResponse);
    if (kDebugMode) {
      print("New title is: ${widget.chatDetails?.title}");
    }

    chat!.summary += await _apiServices.generateSummary(messageResponse);
    chat = await _isarServices.saveChat(chat!, messageResponse);
  }

  _deleteButton() {
    Utils.showMessage(
      context,
      t(context).delete,
      t(context).deleteMessagesConfirmation,
      t(context).no,
      () {
        _popWindow();
      },
      buttonText2: t(context).yes,
      onPressed2: () {
        _selectionProvider.deleteMessages();
        setState(() {});
        _popWindow();
      },
      isConfirmationDialog: true,
    );
  }

  _popWindow() {
    Navigator.of(context).pop();
  }

  Widget noNet() {
    return SafeArea(
      child: Row(
        children: [
          AvatarGlow(
            animate: true,
            glowColor: Colors.redAccent,
            endRadius: _isListening ? 55 : 20,
            child: TextButton(
                onPressed: () {
                  if (!_apiProcess) {
                    _toggleRecording();
                  }
                },
                child: const Icon(Icons.wifi_off)),
          ),
          const SizedBox(width: kDefaultPadding / 3),
          Expanded(
            child: Container(
              //color: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(
                horizontal: kDefaultPadding * 0.40,
              ),
              decoration: BoxDecoration(
                //color: kPrimaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Please connect to Internet'),
                  ),
                  TextButton(
                    onPressed: () {
                      checkConnection();
                    },
                    child: const Text('RETRY'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageCard(Message message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Card(
          color: Colors.transparent,
          child: Container(
            //color: Colors.transparent,
            padding: const EdgeInsets.symmetric(
              horizontal: kDefaultPadding * 0.75,
              vertical: kDefaultPadding / 2,
            ),
            margin: message.isSender
                ? const EdgeInsets.fromLTRB(75, 0, 0, 0)
                : const EdgeInsets.fromLTRB(0, 0, 75, 0),
            decoration: BoxDecoration(
              color: _selectionProvider.containsMessage(message)
                  ? Colors.white
                  : kPrimaryColor.withOpacity(message.isSender ? 1 : 0.3),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: _selectionProvider.containsMessage(message)
                    ? kPrimaryColor
                    : message.isSender
                        ? Colors.white
                        : Theme.of(context).textTheme.bodyLarge!.color,
              ),
            ),
          ),
        ),

        if (message.isSender)
          const SizedBox(
            height: 10,
          ),
        Row(
          children: [
            if (message.isSender) const Expanded(child: SizedBox()),
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
    );
  }

  void changeTitle() {
    if (widget.chatDetails == null) {
      widget.chatDetails =
          ChatDetails(title: t(context).newDiscussion, date: DateTime.now());
    }
    _titleController.text = widget.chatDetails!.title;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              t(context).changeTitle,
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
                    widget.chatDetails!.title = _titleController.text;
                  });
                  chat!.details.value = widget.chatDetails;
                  chat = await _isarServices.saveChat(chat!, null);

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

  PopupMenuItem<MenuItem> _buildShareItems(MenuItem item) {
    return PopupMenuItem<MenuItem>(
        value: item,
        child: Row(
          children: [
            Icon(item.icon),
            const SizedBox(width: 12),
            Text(item.text),
          ],
        ));
  }

  _shareItemSelected(BuildContext context, MenuItem item) {
    if (item == itemCopy) {
      FlutterClipboard.copy(_selectionProvider.messages.first.text)
          .then((value) => Fluttertoast.showToast(msg: t(context).copied));
    } else if (item == itemShare) {
      Share.share(
          "${_selectionProvider.messages.first.text} \n https://play.google.com/store/apps/details?id=$playStoreId");
    }
  }

  // Starts and stops the camera according to the lifecycle of the app
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed &&
        _cameraController != null &&
        _cameraController!.value.isInitialized) {
      _startCamera();
    }
  }

  void _startCamera() {
    if (_cameraController != null) {
      _cameraSelected(_cameraController!.description);
    }
  }

  void _stopCamera() {
    if (_cameraController != null) {
      _cameraController?.dispose();
    }
  }

  void _initCameraController(List<CameraDescription> cameras) {
    if (_cameraController != null) {
      return;
    }

    // Select the first rear camera.
    CameraDescription? camera;
    for (var i = 0; i < cameras.length; i++) {
      final CameraDescription current = cameras[i];
      if (current.lensDirection == CameraLensDirection.back) {
        camera = current;
        break;
      }
    }

    if (camera != null) {
      _cameraSelected(camera);
    }
  }

  Future<void> _cameraSelected(CameraDescription camera) async {
    _cameraController = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
    );

    await _cameraController!.initialize();

    if (!mounted) {
      return;
    }
    setState(() {});
  }
}
