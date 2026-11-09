import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../app_strings.dart';
import '../models/chat_message.dart';
import '../repositories/chat_repository.dart';
import '../viewmodels/assistant_view_model.dart';
import '../viewmodels/locale_provider.dart';

const int _kMaxQuestionLength = 300;

class AssistantScreen extends StatelessWidget {
  final String? serviceId;
  final String? stepId;

  const AssistantScreen({super.key, this.serviceId, this.stepId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AssistantViewModel(
        repository: context.read<ChatRepository>(),
        serviceId: serviceId,
        stepId: stepId,
      ),
      child: _AssistantView(serviceId: serviceId, stepId: stepId),
    );
  }
}

class _AssistantView extends StatefulWidget {
  final String? serviceId;
  final String? stepId;

  const _AssistantView({this.serviceId, this.stepId});

  @override
  State<_AssistantView> createState() => _AssistantViewState();
}

class _AssistantViewState extends State<_AssistantView> {
  final _formKey = GlobalKey<FormState>();
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

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
    final vm = context.watch<AssistantViewModel>();

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
            child: vm.messages.isEmpty
                ? _EmptyState(strings: strings)
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    itemCount: vm.messages.length,
                    itemBuilder: (ctx, i) => _MessageBubble(
                      message: vm.messages[i],
                      strings: strings,
                      // 추천 서비스를 받는 화면은 단계 화면(S05)뿐이다.
                      onServiceTap: widget.serviceId != null
                          ? (id) => Navigator.pop<String>(context, id)
                          : null,
                    ),
                  ),
          ),

          // 전송 중 표시
          if (vm.isSending) const LinearProgressIndicator(),

          // 오류 문구
          if (vm.errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              color: Colors.white,
              child: Text(
                vm.errorMessage!,
                style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.error),
              ),
            ),

          // 입력창
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            color: Colors.white,
            child: Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _inputCtrl,
                      decoration: InputDecoration(
                        hintText: strings.assistantHint,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) return strings.questionEmpty;
                        if (text.length > _kMaxQuestionLength) {
                          return strings.questionTooLong(_kMaxQuestionLength);
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _submit(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    onPressed: vm.isSending ? null : _submit,
                    icon: const Icon(Icons.send, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppTheme.textSecondary,
                      disabledForegroundColor: Colors.white,
                      fixedSize: const Size(44, 44),
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final vm = context.read<AssistantViewModel>();
    if (vm.isSending) return;
    if (!_formKey.currentState!.validate()) return;

    final text = _inputCtrl.text.trim();
    _inputCtrl.clear();
    final sending = vm.send(text, context.read<LocaleProvider>().locale);
    _scrollToBottom();
    await sending;
    if (!mounted) return;
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

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final AppStrings strings;
  final ValueChanged<String>? onServiceTap;

  const _MessageBubble({required this.message, required this.strings, this.onServiceTap});

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
                  final serviceId = ref['serviceId'] as String?;
                  return GestureDetector(
                    onTap: serviceId != null && onServiceTap != null
                        ? () => onServiceTap!(serviceId)
                        : null,
                    child: Container(
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
