import 'package:flutter/material.dart';

enum ChatMessageType { text, goal, cheer, system }

class ChatMessage {
  final String id;
  final String userId;
  final String username;
  final String text;
  final DateTime createdAt;
  final ChatMessageType type;
  final bool isMe;

  const ChatMessage({
    required this.id,
    required this.userId,
    required this.username,
    required this.text,
    required this.createdAt,
    this.type = ChatMessageType.text,
    this.isMe = false,
  });

  // Deterministic color per user — same user always same color
  Color get userColor {
    const palette = [
      Color(0xFF4CAF50), Color(0xFF2196F3), Color(0xFFFF9800),
      Color(0xFF9C27B0), Color(0xFF00BCD4), Color(0xFFFF5722),
      Color(0xFF607D8B), Color(0xFF795548), Color(0xFFE91E63),
      Color(0xFF3F51B5),
    ];
    int hash = 0;
    for (final c in userId.codeUnits) hash = (hash * 31 + c) & 0xFFFFFF;
    return palette[hash % palette.length];
  }
}
