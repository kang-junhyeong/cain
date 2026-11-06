class ChatMessage {
  final String text;
  final bool isUser;
  final String? status;
  final List<Map<String, dynamic>> references;

  const ChatMessage({
    required this.text,
    required this.isUser,
    this.status,
    this.references = const [],
  });
}
