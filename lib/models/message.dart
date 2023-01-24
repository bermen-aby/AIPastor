import 'package:isar/isar.dart';

import 'chat_model.dart';

part 'message.g.dart';

@collection
class Message {
  Id id = Isar.autoIncrement;
  final String text;
  final DateTime date;
  final bool isSender;

  final chat = IsarLink<Chat>();

  Message({
    required this.text,
    required this.date,
    required this.isSender,
  });
}
