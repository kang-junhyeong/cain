import 'package:cain/repositories/demo_chat_scripts.dart';
import 'package:flutter_test/flutter_test.dart';

String? answer(String q) => DemoChatScripts.match(q)?.answer;

void main() {
  test('3턴 대본', () {
    expect(answer('학생증을 잃어버렸는데 어떻게 해야 해?'), contains('결제 기능'));
    expect(answer('아니, 결제 기능은 없고 학교에서 쓰는 학생증이야. 어디서 재발급받고 뭘 챙겨가야 해?'), contains('증명사진'));
    expect(answer('새 학생증이 나올 때까지 도서관은 어떻게 이용해?'), contains('모바일 학생증'));
  });

  test('4턴 대본', () {
    expect(answer('아니, 결제 기능은 없고 학교에서 사용하는 학생증이야. 어디서 다시 발급받아?'), contains('041-123-4567'));
    expect(answer('신청할 때 준비해야 할 게 있어?'), contains('5,000원'));
  });

  test('증명서 질문·무관한 질문은 대본에 안 걸린다', () {
    expect(answer('재학 증명서 어디서 발급해?'), isNull);
    expect(answer('식당 메뉴 알려줘'), isNull);
  });
}
