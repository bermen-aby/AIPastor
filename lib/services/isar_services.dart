import 'dart:io';

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

  Future<void> saveChat(Chat newChat, Message? message) async {
    final isar = await db;

    final chat = await isar.chats.get(newChat.id) ?? Chat();
    chat
      ..summary = newChat.summary
      ..details.value = newChat.details.value;
    if (message != null) {
      chat.messages.add(message);
    }

    isar.writeTxn(
      () async {
        if (message != null) {
          await isar.messages.put(message);
        }
        await isar.chats.put(chat);
        await isar.chatDetails.put(newChat.details.value!);
        await chat.details.save();
        await chat.messages.save();
      },
    );
  }

  Future<void> saveDetails(ChatDetails newChatDetails) async {
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
      await chat.details.load();
      await chat.messages.load();
      chat.details.value = null;
      chat.messages.clear();

      isar.writeTxnSync(
        () async {
          await chat.details.save();
          await chat.messages.save();
          await isar.chats.delete(chat.id);
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
      isar.writeTxnSync(
        () async {
          await chatDetails.chat.save();
          await isar.chatDetails.delete(chatDetails.id);
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
}
