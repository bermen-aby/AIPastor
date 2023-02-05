import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/chat_model.dart';
import '../models/chat_details.dart';
import '../models/message.dart';

class IsarServices {
  late Future<Isar> db;

  IsarServices() {
    db = openDB();
  }

  Future<Chat> saveChat(Chat newChat, Message? newMessage) async {
    final isar = await db;

    debugPrint("LOG: newChat.id : ${newChat.id}");

    final chat = await isar.chats.get(newChat.id) ?? Chat();
    chat
      ..summary = newChat.summary
      ..details.value = newChat.details.value;
    late Message message;

    if (chat.messages.isAttached) {
      await chat.messages.load();
    }
    if (newMessage != null) {
      message = await isar.messages.get(newMessage.id) ??
          Message(
              text: newMessage.text,
              date: newMessage.date,
              isSender: newMessage.isSender);
    }

    isar.writeTxn(
      () async {
        await isar.chats.put(chat);
        await isar.chatDetails.put(newChat.details.value!);
        await chat.details.save();

        if (newMessage != null) {
          // chat.messages.add(message);
          message.chat.value = chat;
          message.id = await isar.messages.put(message);
          chat.messages.add(message);

          if (chat.messages.isAttached) {
            await chat.messages.save();
          }

          debugPrint(
              "LOG: chat.messages is not empty: ${chat.messages.isNotEmpty}");
        }
      },
    );

    return chat;
  }

  Future<ChatDetails> saveDetails(ChatDetails newChatDetails) async {
    final isar = await db;
    final chatDetails =
        await isar.chatDetails.get(newChatDetails.id) ?? newChatDetails;
    chatDetails
      ..date = newChatDetails.date
      ..lastMessage = newChatDetails.lastMessage
      ..title = newChatDetails.title;

    isar.writeTxn(
      () async {
        await isar.chatDetails.put(chatDetails);
        await chatDetails.chat.save();
      },
    );

    return chatDetails;
  }

  Future<Chat?> getChat(ChatDetails chat) async {
    final isar = await db;
    final chatDetails =
        await isar.chatDetails.filter().idEqualTo(chat.id).findFirst();

    return chatDetails?.chat.value;
  }

  Future<List<Message>> getChatMessages(Chat chat) async {
    final isar = await db;
    final messages = await isar.messages
        .filter()
        .chat((q) => q.idEqualTo(chat.id))
        .findAll();

    return messages;
  }

  Future<List<ChatDetails?>> getAllChatSmall() async {
    final isar = await db;
    final result = await isar.chatDetails.where().findAll();

    return result;
  }

  Future<void> removeMessage(Message toRemove) async {
    final isar = await db;
    final message = await isar.messages.get(toRemove.id);

    if (message != null) {
      isar.writeTxn(
        () async {
          await isar.messages.delete(message.id);
        },
      );
    }
  }

  Future<void> removeChat(Chat newChat) async {
    final isar = await db;

    final chat = await isar.chats.get(newChat.id);

    if (chat != null) {
      final messages = await isar.messages
          .filter()
          .chat((q) => q.idEqualTo(chat.id))
          .findAll();
      await chat.details.load();
      await chat.messages.load();
      chat.details.value = null;
      chat.messages.clear();
      List<int> ids = [];
      for (var element in messages) {
        ids.add(element.id);
      }

      isar.writeTxn(
        () async {
          await isar.chats.delete(chat.id);
          await isar.messages.deleteAll(ids);
          await chat.details.save();
          await chat.messages.save();
        },
      );
    }
  }

  Future<void> removeChatFromDetails(ChatDetails newChatD) async {
    final isar = await db;
    final chatDetails = await isar.chatDetails.get(newChatD.id);
    late Chat? chat;
    if (chatDetails != null) {
      chat = await getChat(chatDetails);
    }

    if (chatDetails != null) {
      await chatDetails.chat.load();
      chatDetails.chat.value = null;
      isar.writeTxn(
        () async {
          await isar.chatDetails.delete(chatDetails.id);
          await chatDetails.chat.save();
        },
      );
      if (chat != null) {
        removeChat(chat);
      }
    }
  }

  Future<Isar> openDB() async {
    final Directory appDocDirectory = await getApplicationDocumentsDirectory();
    final String appDocPath = appDocDirectory.path;
    if (Isar.instanceNames.isEmpty) {
      return await Isar.open(
        [ChatSchema, ChatDetailsSchema, MessageSchema],
        inspector: true,
        directory: appDocPath,
      );
    }

    return Future.value(Isar.getInstance());
  }

  saveChatDetails(ChatDetails first) {}
}
