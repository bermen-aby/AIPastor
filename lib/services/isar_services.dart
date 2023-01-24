import 'dart:io';

import 'package:isar/isar.dart';
import 'package:newapp/models/chat_model.dart';
import 'package:newapp/models/chat_small_model.dart';
import 'package:newapp/models/message.dart';
import 'package:path_provider/path_provider.dart';

class IsarServices {
  late Future<Isar> db;

  IsarServices() {
    db = openDB();
  }

  Future<void> saveChat(Chat newChat, List<Message> messages) async {
    final isar = await db;
    final smallChat = ChatSmall(
      name: newChat.name,
      time: newChat.time,
      lastMessage: newChat.lastMessage,
      isActive: newChat.isActive,
      image: newChat.image,
    );
    isar.writeTxn(
      () async {
        await isar.chats.put(newChat);
        await isar.chatSmalls.put(smallChat);
        await isar.messages.putAll(messages);
        await newChat.messages.save();
      },
    );
  }

  Future<Chat?> getChat(ChatSmall chat) async {
    final isar = await db;
    return await isar.chats.filter().idEqualTo(chat.id).findFirst();
  }

  Future<List<Message>> getChatMessages(ChatSmall chatSmall) async {
    final isar = await db;
    return await isar.messages
        .filter()
        .chat((q) => q.idEqualTo(chatSmall.id))
        .findAll();
  }

  Future<List<ChatSmall?>> getAllChatSmall() async {
    final isar = await db;
    final result = await isar.chatSmalls.where().findAll();

    return result;
  }

  Future<void> removeMessage(Message message) async {
    final isar = await db;
    isar.writeTxn(
      () async {
        await isar.messages.delete(message.id);
        // final chat = await isar.chats
        //     .filter()
        //     .messages((q) => q.idEqualTo(message.id))
        //     .findFirst();
        // await isar.chats.get(chat!.id).;
      },
    );
  }

  Future<void> removeChat(Chat chat) async {
    final isar = await db;
    isar.writeTxnSync(
      () async {
        await isar.chats.delete(chat.id);
        await isar.chatSmalls.delete(chat.id);
      },
    );
  }

  Future<void> removeChatSmall(ChatSmall chat) async {
    final isar = await db;
    isar.writeTxnSync(
      () async {
        await isar.chats.delete(chat.id);
        await isar.chatSmalls.delete(chat.id);
      },
    );
  }

  Future<Isar> openDB() async {
    final Directory appDocDirectory = await getApplicationDocumentsDirectory();
    final String appDocPath = appDocDirectory.path;
    if (Isar.instanceNames.isEmpty) {
      return await Isar.open(
        [ChatSchema, ChatSmallSchema, MessageSchema],
        inspector: true,
        directory: appDocPath,
      );
    }

    return Future.value(Isar.getInstance());
  }
}
