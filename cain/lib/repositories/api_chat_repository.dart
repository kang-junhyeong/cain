import '../models/chat_answer.dart';
import '../services/chat_api_service.dart';
import 'chat_repository.dart';

class ApiChatRepository implements ChatRepository {
  final ChatApiService _service;

  ApiChatRepository({required ChatApiService service}) : _service = service;

  @override
  Future<ChatAnswer> ask({
    required String question,
    required String locale,
    String? serviceId,
    String? stepId,
  }) async {
    final map = await _service.postChat(
      question: question,
      locale: locale,
      serviceId: serviceId,
      stepId: stepId,
    );
    return ChatAnswer.fromJson(map);
  }
}
