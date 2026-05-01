
enum MessageRole { user, model }

class AiChatMessage {
  final String text;
  final MessageRole role;
  final DateTime createdAt;
  final bool isLoading;

  AiChatMessage({
    required this.text,
    required this.role,
    DateTime? createdAt,
    this.isLoading = false,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isUser => role == MessageRole.user;
}
