// TODO(AI 보류): FastAPI 서버 배포 후 HTTP 호출 코드 활성화
//
// 현재 상태:
//   - UI 구조 완성
//   - HTTP 호출 코드 전체 주석 처리
//   - 더미 응답으로 대체 동작
//
// 재개 조건:
//   1. FastAPI 서버 배포 URL 확정 (윤우성)
//   2. 아래 _kApiBase 에 실제 서버 URL 입력
//   3. _sendMessage() 내 주석 해제
//   4. 실제 테스트 후 오류 처리 확인
//
// API 계약: DEV_NOTES.md 및 개발 기획서.md 섹션 06·07 참조

import 'dart:convert';
// import 'package:http/http.dart' as http; // TODO(AI 보류): 활성화

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme.dart';
import '../../core/locale/locale_provider.dart';

// TODO(AI 보류): 서버 배포 후 실제 URL로 교체
const String _kApiBase = 'TODO: https://your-server.com';
const String _kContentVersion = '2026.11.03.1';

class AssistantScreen extends StatefulWidget {
  final String? serviceId;
  final String? stepId;

  const AssistantScreen({super.key, this.serviceId, this.stepId});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isSending = false;

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale;
    final strings = AppStrings(locale);

    return Scaffold(
      appBar: AppBar(title: Text(strings.assistantTitle)),
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // 컨텍스트 배지 (서비스/단계 참고 중)
          if (widget.serviceId != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppTheme.primary.withOpacity(0.07),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 15, color: AppTheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.serviceId}${widget.stepId != null ? ' · ${widget.stepId}' : ''} 참고 중',
                    style: const TextStyle(fontSize: 12, color: AppTheme.primary),
                  ),
                ],
              ),
            ),

          // 메시지 목록
          Expanded(
            child: _messages.isEmpty
                ? _EmptyState(strings: strings)
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (ctx, i) => _MessageBubble(message: _messages[i], strings: strings),
                  ),
          ),

          // 입력창
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputCtrl,
                    decoration: InputDecoration(
                      hintText: strings.assistantHint,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(locale, strings),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _isSending ? null : () => _sendMessage(locale, strings),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _isSending ? AppTheme.textSecondary : AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: _isSending
                        ? const Padding(
                            padding: EdgeInsets.all(10),
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(String locale, AppStrings strings) async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _isSending) return;

    _inputCtrl.clear();
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isSending = true;
    });
    _scrollToBottom();

    // ─────────────────────────────────────────────────────────────────
    // TODO(AI 보류): 아래 주석을 해제하고 더미 응답 코드를 삭제하세요
    // ─────────────────────────────────────────────────────────────────
    //
    // try {
    //   final response = await http.post(
    //     Uri.parse('$_kApiBase/api/v1/chat'),
    //     headers: {'Content-Type': 'application/json'},
    //     body: jsonEncode({
    //       'question': text,
    //       'locale': locale,
    //       'contentVersion': _kContentVersion,
    //       'context': {
    //         'serviceId': widget.serviceId,
    //         'stepId': widget.stepId,
    //       },
    //     }),
    //   ).timeout(const Duration(seconds: 30));
    //
    //   if (response.statusCode == 200) {
    //     final data = jsonDecode(response.body) as Map<String, dynamic>;
    //     final status = data['status'] as String;
    //     final answer = data['answer'] as String? ?? strings.aiUnavailable;
    //     final refs = (data['references'] as List<dynamic>? ?? []);
    //
    //     setState(() {
    //       _messages.add(_ChatMessage(
    //         text: answer,
    //         isUser: false,
    //         status: status,
    //         references: refs.cast<Map<String, dynamic>>(),
    //       ));
    //     });
    //   } else if (response.statusCode == 409) {
    //     setState(() => _messages.add(_ChatMessage(text: '앱 데이터 버전이 맞지 않습니다. 앱을 업데이트해 주세요.', isUser: false)));
    //   } else if (response.statusCode == 429) {
    //     setState(() => _messages.add(_ChatMessage(text: '잠시 후 다시 질문해 주세요.', isUser: false)));
    //   } else {
    //     setState(() => _messages.add(_ChatMessage(text: strings.aiUnavailable, isUser: false)));
    //   }
    // } on TimeoutException {
    //   setState(() => _messages.add(_ChatMessage(text: strings.aiUnavailable, isUser: false)));
    // } catch (e) {
    //   setState(() => _messages.add(_ChatMessage(text: strings.aiUnavailable, isUser: false)));
    // }

    // 더미 응답 (서버 연동 전까지 임시 사용)
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _messages.add(_ChatMessage(
        text: '[서버 미연결] AI 기능은 서버 배포 후 이용할 수 있습니다.\n\n'
            'In-app guides are available now. Please check the step-by-step guide for your service.',
        isUser: false,
        status: 'insufficient_evidence',
        references: const [],
      ));
    });
    // ─────────────────────────────────────────────────────────────────

    setState(() => _isSending = false);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final String? status;
  final List<Map<String, dynamic>> references;

  const _ChatMessage({
    required this.text,
    required this.isUser,
    this.status,
    this.references = const [],
  });
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  final AppStrings strings;

  const _MessageBubble({required this.message, required this.strings});

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(4),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Text(message.text, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5)),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, right: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI 아이콘
            const Row(
              children: [
                Icon(Icons.smart_toy, size: 14, color: AppTheme.accent),
                SizedBox(width: 4),
                Text('AI', style: TextStyle(fontSize: 11, color: AppTheme.accent, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),
            Text(message.text, style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary, height: 1.6)),

            // 출처 라벨
            if (message.references.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                children: message.references.map((ref) {
                  final kind = ref['kind'] as String? ?? 'official';
                  final label = ref['label'] as String? ?? '';
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: kind == 'official'
                          ? AppTheme.primary.withOpacity(0.08)
                          : AppTheme.accent.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${kind == 'official' ? strings.officialLabel : strings.tipLabel}: $label',
                      style: TextStyle(
                        fontSize: 11,
                        color: kind == 'official' ? AppTheme.primary : AppTheme.accent,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            // 도움 됐어요 / 다시 질문
            const SizedBox(height: 10),
            Row(
              children: [
                const Spacer(),
                _FeedbackButton(
                  icon: Icons.thumb_up_outlined,
                  label: strings.helpful,
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                _FeedbackButton(
                  icon: Icons.refresh,
                  label: strings.askAgain,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FeedbackButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 3),
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppStrings strings;
  const _EmptyState({required this.strings});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy, size: 40, color: AppTheme.accent),
          ),
          const SizedBox(height: 16),
          Text(
            strings.assistantTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              strings.aiAssistantDesc,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
