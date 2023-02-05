// ignore_for_file: prefer_final_fields, avoid_function_literals_in_foreach_calls

import 'package:ai_pastor/models/chat_details.dart';
import 'package:ai_pastor/models/message.dart';
import 'package:ai_pastor/services/isar_services.dart';
import 'package:flutter/cupertino.dart';

class SelectionProvider with ChangeNotifier {
  bool _selectionMode = false;
  bool get selectionMode => _selectionMode;
  List<ChatDetails> _chatsDetails = [];
  List<ChatDetails> get chatsDetails => _chatsDetails;
  List<Message> _messages = [];
  List<Message> get messages => _messages;

  set selectionMode(bool mode) {
    _selectionMode = mode;
    notifyListeners();
  }

  addChatsDetails(ChatDetails chatDetails) {
    _chatsDetails.add(chatDetails);
    notifyListeners();
  }

  removeChatsDetails(ChatDetails chatDetails) {
    _chatsDetails.remove(chatDetails);
    notifyListeners();
  }

  clearChatsDetails(ChatDetails chatDetails) {
    _chatsDetails.clear();
    notifyListeners();
  }

  addMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }

  removeMessage(Message message) {
    _messages.remove(message);
    notifyListeners();
  }

  clearMessage(Message message) {
    _messages.clear();
    notifyListeners();
  }

  addOrRemoveChatDetails(ChatDetails chatDetails) {
    if (_chatsDetails.isNotEmpty) {
      for (var i = 0; i < _chatsDetails.length; i++) {
        if (_chatsDetails[i].lastMessage == chatDetails.lastMessage &&
            _chatsDetails[i].date == chatDetails.date) {
          _chatsDetails.removeAt(i);
          if (_chatsDetails.isEmpty) {
            _selectionMode = false;
          }
          return false;
        }
      }
    }
    _chatsDetails.add(chatDetails);
    notifyListeners();
    return true;
  }

  bool containsChatDetails(ChatDetails chatDetails) {
    bool result = false;
    for (var element in _chatsDetails) {
      if (element.lastMessage == chatDetails.lastMessage &&
          element.date == chatDetails.date) {
        result = true;
        return result;
      }
    }
    return result;
  }

  Future<bool> deleteChatsDetails() async {
    final isarServices = IsarServices();
    // for (var i = 0; i < _chatsDetails.length; i++) {
    //   await isarServices.removeChatFromDetails(_chatsDetails[i]);
    // }
    _chatsDetails.forEach((element) {
      isarServices.removeChatFromDetails(element);
    });
    _chatsDetails.clear();
    _selectionMode = false;
    notifyListeners();
    return true;
  }

  Future<bool> deleteMessages() async {
    final isarServices = IsarServices();
    // for (var i = 0; i < _messages.length; i++) {
    //   await isarServices.removeMessage(_messages[i]);
    // }
    _messages.forEach((element) async {
      await isarServices.removeMessage(element);
    });
    _messages.clear();
    _selectionMode = false;
    notifyListeners();
    return true;
  }

  init() {
    _chatsDetails.clear();
    _messages.clear();
    _selectionMode = false;
  }

  bool addOrRemoveMessage(Message message) {
    if (_messages.isNotEmpty) {
      for (var i = 0; i < _messages.length; i++) {
        if (_messages[i].text == message.text &&
            _messages[i].date == message.date) {
          _messages.removeAt(i);
          if (_messages.isEmpty) {
            _selectionMode = false;
          }
          return false;
        }
      }
    }
    _messages.add(message);
    notifyListeners();
    return true;
  }

  bool containsMessage(Message message) {
    bool result = false;
    for (var element in _messages) {
      if (element.text == message.text && element.date == message.date) {
        result = true;
        return result;
      }
    }
    return result;
  }
}
