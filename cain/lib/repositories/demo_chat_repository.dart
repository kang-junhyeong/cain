import '../app_strings.dart';
import '../models/chat_answer.dart';
import '../models/service.dart';
import 'chat_repository.dart';
import 'service_repository.dart';

/// 서버 없이 시연할 때 쓰는 구현.
/// 질문에 "error"나 "오류"가 들어가면 예외를 던져 오류 화면도 볼 수 있다.
class DemoChatRepository implements ChatRepository {
  final ServiceRepository _serviceRepository;

  DemoChatRepository({required ServiceRepository serviceRepository})
      : _serviceRepository = serviceRepository;

  @override
  Future<ChatAnswer> ask({
    required String question,
    required String locale,
    String? serviceId,
    String? stepId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final lower = question.toLowerCase();
    if (lower.contains('error') || lower.contains('오류')) {
      throw Exception('demo error');
    }

    final strings = AppStrings(locale);
    final service = await _findService(lower, locale, serviceId);
    if (service == null) {
      return ChatAnswer(status: 'insufficient_evidence', answer: strings.demoNoMatch);
    }

    final title = service.title.resolve(locale);
    return ChatAnswer(
      status: 'answered',
      answer: strings.demoAnswer(
        title,
        service.location.resolve(locale),
        service.hours.resolve(locale),
      ),
      references: [
        {
          'id': 'demo_${service.id}',
          'kind': 'official',
          'label': title,
          'serviceId': service.id,
        },
      ],
    );
  }

  /// 질문에 서비스 이름이 있으면 그 서비스를, 없으면 지금 보고 있는 서비스를 고른다.
  Future<ServiceModel?> _findService(String question, String locale, String? serviceId) async {
    final compact = question.replaceAll(' ', '');
    for (final service in await _serviceRepository.getAll()) {
      final title = service.title.resolve(locale).toLowerCase().replaceAll(' ', '');
      if (compact.contains(title)) return service;
    }
    return serviceId == null ? null : _serviceRepository.getById(serviceId);
  }
}
