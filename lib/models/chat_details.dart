import 'package:isar/isar.dart';

import 'chat_model.dart';

part 'chat_details.g.dart';

@collection
class ChatDetails {
  Id id = Isar.autoIncrement;
  String title;
  String lastMessage;
  late DateTime date;

  final chat = IsarLink<Chat>();

  ChatDetails({
    this.title = '',
    this.lastMessage = '',
    required this.date,
  });
}
