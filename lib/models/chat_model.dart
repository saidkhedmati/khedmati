import 'package:cloud_firestore/cloud_firestore.dart';

/// محادثة بين شخصين (مرتبطة بطلب خدمة معين)
class ChatModel {
  final String id;
  final String requestId;
  final String requestTitle;
  final List<String> participantIds; // [صاحب الطلب, الشخص الآخر]
  final String lastMessage;
  final DateTime lastMessageAt;

  ChatModel({
    required this.id,
    required this.requestId,
    required this.requestTitle,
    required this.participantIds,
    this.lastMessage = '',
    DateTime? lastMessageAt,
  }) : lastMessageAt = lastMessageAt ?? DateTime.now();

  factory ChatModel.fromMap(String id, Map<String, dynamic> map) {
    return ChatModel(
      id: id,
      requestId: map['requestId'] ?? '',
      requestTitle: map['requestTitle'] ?? '',
      participantIds: List<String>.from(map['participantIds'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageAt: map['lastMessageAt'] != null
          ? (map['lastMessageAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'requestTitle': requestTitle,
      'participantIds': participantIds,
      'lastMessage': lastMessage,
      'lastMessageAt': Timestamp.fromDate(lastMessageAt),
    };
  }
}

/// رسالة وحدة جوا محادثة
class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final DateTime sentAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    DateTime? sentAt,
  }) : sentAt = sentAt ?? DateTime.now();

  factory MessageModel.fromMap(String id, Map<String, dynamic> map) {
    return MessageModel(
      id: id,
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      sentAt: map['sentAt'] != null
          ? (map['sentAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'sentAt': Timestamp.fromDate(sentAt),
    };
  }
}
