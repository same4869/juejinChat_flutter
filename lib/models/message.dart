import 'package:floor/floor.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// @freezed
// class Message with _$Message {
//   const factory Message({
//     required String content,
//     required DateTime timestamp,
//     required bool isUser,
//     required String id,
//   }) = _Message;

//   factory Message.fromJson(Map<String, Object?> json) =>
//       _$MessageFromJson(json);
// }

@entity
class Message {
  @primaryKey
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
  });
}

extension MessageExtension on Message {
  Message copyWith(
      {String? id, String? content, bool? isUser, DateTime? timestamp}) {
    return Message(
        content: content ?? this.content,
        id: id ?? this.id,
        isUser: isUser ?? this.isUser,
        timestamp: timestamp ?? this.timestamp);
  }
}
