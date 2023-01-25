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

    isar.writeTxn(
      () async {
        final chat = await isar.chats.get(newChat.id) ?? Chat();
        chat
          ..summary = newChat.summary
          ..details.value = newChat.details.value;
        if (message != null) {
          chat.messages.add(message);
        }
        await isar.chats.put(chat);
        if (message != null) {
          await isar.messages.put(message);
        }
        await isar.chatDetails.put(newChat.details.value!);
        await chat.messages.save();
        await chat.details.save();
      },
    );
  }

  Future<void> saveDetails(ChatDetails newChatDetails) async {
    final isar = await db;

    isar.writeTxn(
      () async {
        final chatDetails =
            await isar.chatDetails.get(newChatDetails.id) ?? newChatDetails;
        chatDetails
          ..date = newChatDetails.date
          ..lastMessage = newChatDetails.lastMessage
          ..title = newChatDetails.title;

        await isar.chatDetails.put(chatDetails);
        await chatDetails.chat.save();
      },
    );
  }

  // Future<void> updateChat(Chat newChat, List<Message> messages) async {
  //   final isar = await db;
  //   final smallChat = ChatDetails(
  //     title: newChat.title,
  //     date: newChat.time,
  //     lastMessage: newChat.lastMessage,
  //     isActive: newChat.isActive,
  //     image: newChat.image,
  //   );
  //   isar.writeTxn(
  //     () async {
  //       await isar.chats.put(newChat);
  //       await isar.chatDetails.put(smallChat);
  //       await isar.messages.putAll(messages);
  //       await newChat.messages.save();
  //     },
  //   );
  // }

  Future<Chat?> getChat(ChatDetails chat) async {
    final isar = await db;
    final chatDetails =
        await isar.chatDetails.filter().idEqualTo(chat.id).findFirst();

    return chatDetails?.chat.value;
  }

  Future<List<Message>> getChatMessages(Chat chat) async {
    final isar = await db;
    return await isar.messages
        .filter()
        .chat((q) => q.idEqualTo(chat.id))
        .findAll();
  }

  Future<List<ChatDetails?>> getAllChatSmall() async {
    final isar = await db;
    final result = await isar.chatDetails.where().findAll();

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
        await isar.chatDetails.delete(chat.id);
      },
    );
  }

  Future<void> removeChatSmall(ChatDetails chat) async {
    final isar = await db;
    isar.writeTxnSync(
      () async {
        await isar.chats.delete(chat.id);
        await isar.chatDetails.delete(chat.id);
      },
    );
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
