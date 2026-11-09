class ChatAnswer {
  final String status;
  final String answer;
  final List<Map<String, dynamic>> references;

  const ChatAnswer({
    required this.status,
    required this.answer,
    this.references = const [],
  });

  factory ChatAnswer.fromJson(Map<String, dynamic> json) {
    return ChatAnswer(
      status: json['status'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      references: (json['references'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>(),
    );
  }
}
