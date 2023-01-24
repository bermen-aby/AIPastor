import 'package:isar/isar.dart';

part 'chat_small_model.g.dart';

@collection
class ChatSmall {
  Id id = Isar.autoIncrement;
  String name;
  String lastMessage;
  late DateTime time;
  //String time;
  String image;
  final bool isActive;

  ChatSmall({
    this.name = '',
    this.lastMessage = '',
    this.image = '',
    required this.time,
    this.isActive = false,
  });
}
