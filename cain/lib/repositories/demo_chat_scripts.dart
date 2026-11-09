import '../models/chat_answer.dart';

/// 시연 영상용 고정 대화 (학생증 분실 → 재발급 → 도서관 이용).
///
/// 서버 없이 데모 모드로 돌릴 때, 질문 키워드에 맞는 답을 그대로 돌려준다.
/// 부서·위치·연락처·비용 등은 모두 시연용 가상 정보다. TODO(실제 정보): 확인 후 교체
///
/// 대본 (3턴 버전)
///   1. 학생증을 잃어버렸는데 어떻게 해야 해?
///   2. 아니, 결제 기능은 없고 학교에서 쓰는 학생증이야. 어디서 재발급받고 뭘 챙겨가야 해?
///   3. 새 학생증이 나올 때까지 도서관은 어떻게 이용해?
/// 4턴 버전(2번을 "어디서 다시 발급받아?" / "신청할 때 준비해야 할 게 있어?"로 나눠 묻기)도 동작한다.
class DemoChatScripts {
  const DemoChatScripts._();

  /// 질문에 맞는 시연용 답. 해당 없으면 null.
  static ChatAnswer? match(String question) {
    final q = question.replaceAll(' ', '');
    bool has(List<String> words) => words.any(q.contains);

    // 증명서 질문은 기존 서비스 안내(데모 응답)로 넘긴다.
    if (has(['증명서'])) return null;

    // 순서 중요: 더 구체적인 질문부터 검사한다.
    if (has(['도서관'])) return _answer(_library, '도서관 이용 안내');

    final asksWhere = has(['발급', '어디서', '어디로', '어디가']);
    final asksPrep = has(['준비', '챙겨', '필요한', '필요해', '가져가']);
    if (asksWhere && asksPrep) return _answer(_whereAndPrep, '학생증 재발급 안내');
    if (asksWhere) return _answer(_where, '학생증 재발급 안내');
    if (asksPrep) return _answer(_prep, '학생증 재발급 안내');

    if (has(['학생증']) && has(['잃어', '분실', '잊어버', '없어졌'])) return _answer(_lost, null);

    return null;
  }

  static ChatAnswer _answer(String text, String? referenceLabel) => ChatAnswer(
        status: 'answered',
        answer: text,
        references: referenceLabel == null
            ? const []
            : [
                {'id': 'demo_student_id', 'kind': 'official', 'label': referenceLabel},
              ],
      );

  static const _lost = '학생증을 분실하셨군요. 분실 신고와 재발급 절차를 안내해 드릴게요.\n\n'
      '먼저, 잃어버린 학생증에 체크카드 같은 결제 기능도 있나요?';

  static const _where = '결제 기능이 없는 학생증이라면 학생지원팀에 방문해서 재발급을 신청하시면 돼요.\n\n'
      '• 담당 부서: 학생지원팀\n'
      '• 위치: 학생회관 1층\n'
      '• 연락처: 041-123-4567\n\n'
      '신청 전에 학생 포털 > 학적 > 학생증 분실 신고를 먼저 해 주세요.';

  static const _prep = '재발급 신청에는 아래 준비물이 필요해요.\n\n'
      '• 준비물: 신분증, 증명사진 1매(3×4cm)\n'
      '• 재발급 비용: 5,000원\n'
      '• 발급 기간: 약 3~5일 (주말 제외)\n'
      '• 수령 방법: 학생지원팀 방문 수령\n\n'
      '운영시간은 평일 09:00~18:00 (점심 12:00~13:00)이에요.';

  static const _whereAndPrep = '결제 기능이 없다면 학생지원팀에서 재발급받으면 돼요.\n\n'
      '• 위치: 학생회관 1층 학생지원팀 (평일 09:00~18:00)\n'
      '• 준비물: 신분증, 증명사진 1매\n'
      '• 비용: 5,000원 · 발급까지 약 3~5일\n\n'
      '방문 전에 학생 포털에서 분실 신고를 먼저 해 주세요.';

  static const _library = '새 학생증이 나올 때까지는 모바일 학생증으로 도서관을 이용할 수 있어요.\n\n'
      '학교 앱 > 모바일 학생증에서 QR 코드를 띄운 뒤 출입 게이트에 찍으면 돼요.\n\n'
      '도서 대출은 확인 절차가 다를 수 있으니, 어려우면 도서관 대출실(041-123-4600)에 문의해 주세요.';
}
