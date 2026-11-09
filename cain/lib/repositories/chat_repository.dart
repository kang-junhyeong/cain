import '../models/chat_answer.dart';

abstract class ChatRepository {
  Future<ChatAnswer> ask({
    required String question,
    required String locale,
    String? serviceId,
    String? stepId,
  });
}
