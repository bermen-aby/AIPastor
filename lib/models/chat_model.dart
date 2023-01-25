import 'package:ai_pastor/models/chat_details.dart';
import 'package:isar/isar.dart';

import 'message.dart';

part 'chat_model.g.dart';

@collection
class Chat {
  Id id = Isar.autoIncrement;
  String summary;
  @Backlink(to: "chat")
  final messages = IsarLinks<Message>();
  @Backlink(to: "chat")
  final details = IsarLink<ChatDetails>();

  Chat({
    this.summary = '',
  });
}
