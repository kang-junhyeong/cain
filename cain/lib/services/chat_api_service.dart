import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// 서버가 200이 아닌 상태 코드를 돌려줬을 때 던지는 예외
class ChatApiException implements Exception {
  final int statusCode;

  const ChatApiException(this.statusCode);

  @override
  String toString() => 'ChatApiException($statusCode)';
}

class ChatApiService {
  static const _contentVersion = '2026.11.03.1';
  static const _timeout = Duration(seconds: 30);

  final String baseUrl;

  const ChatApiService({required this.baseUrl});

  Future<Map<String, dynamic>> postChat({
    required String question,
    required String locale,
    String? serviceId,
    String? stepId,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/v1/chat'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'question': question,
            'locale': locale,
            'contentVersion': _contentVersion,
            'context': {
              'serviceId': serviceId,
              'stepId': stepId,
            },
          }),
        )
        .timeout(_timeout, onTimeout: () => throw TimeoutException('chat request', _timeout));

    if (response.statusCode != 200) {
      throw ChatApiException(response.statusCode);
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
