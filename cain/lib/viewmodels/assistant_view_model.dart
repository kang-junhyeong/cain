import 'dart:async';
import 'package:flutter/foundation.dart';
import '../app_strings.dart';
import '../models/chat_message.dart';
import '../repositories/chat_repository.dart';
import '../services/chat_api_service.dart';

class AssistantViewModel extends ChangeNotifier {
  final ChatRepository _repository;
  final String? _serviceId;
  final String? _stepId;

  AssistantViewModel({
    required ChatRepository repository,
    String? serviceId,
    String? stepId,
  })  : _repository = repository,
        _serviceId = serviceId,
        _stepId = stepId;

  final List<ChatMessage> _messages = [];
  bool _isSending = false;
  String? _errorMessage;
  bool _disposed = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;

  Future<void> send(String question, String locale) async {
    if (_isSending || _disposed) return;

    final strings = AppStrings(locale);
    _messages.add(ChatMessage(text: question, isUser: true));
    _isSending = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.ask(
        question: question,
        locale: locale,
        serviceId: _serviceId,
        stepId: _stepId,
      );
      _messages.add(ChatMessage(
        text: result.answer.isEmpty ? strings.aiUnavailable : result.answer,
        isUser: false,
        status: result.status,
        references: result.references,
      ));
    } on TimeoutException {
      _errorMessage = strings.aiTimeout;
    } on ChatApiException catch (e) {
      if (e.statusCode == 409) {
        _errorMessage = strings.aiVersionMismatch;
      } else if (e.statusCode == 429) {
        _errorMessage = strings.aiRateLimited;
      } else {
        _errorMessage = strings.aiUnavailable;
      }
    } catch (_) {
      _errorMessage = strings.aiUnavailable;
    } finally {
      _isSending = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
