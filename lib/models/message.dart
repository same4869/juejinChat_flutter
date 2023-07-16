import 'package:floor/floor.dart';

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
  @ForeignKey(
      childColumns: ["session_id"], parentColumns: ['id'], entity: Message)
  @ColumnInfo(name: "session_id")
  final int? sessionId;

  Message({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.sessionId,
  });

  @override
  String toString() {
    return "Message(id: $id, content: $content, isUser: $isUser, timestamp: $timestamp)";
  }

  @override
  bool operator ==(other) {
    if (identical(this, other)) return true;
    return other is Message && other.id == id;
  }

  @override
  int get hashCode =>
      id.hashCode ^ content.hashCode ^ isUser.hashCode ^ timestamp.hashCode;
}

extension MessageExtension on Message {
  Message copyWith(
      {String? id,
      String? content,
      bool? isUser,
      DateTime? timestamp,
      int? sessionId}) {
    return Message(
        content: content ?? this.content,
        id: id ?? this.id,
        isUser: isUser ?? this.isUser,
        timestamp: timestamp ?? this.timestamp,
        sessionId: sessionId ?? this.sessionId);
  }
}
