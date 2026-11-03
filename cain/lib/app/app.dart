import 'package:flutter/material.dart';
import '../features/assistant/assistant_screen.dart';
// TODO(지도 보류): 지도 구현 후 주석 해제
// import '../features/campus/campus_screen.dart';
import '../features/directory/directory_screen.dart';
import '../features/guides/completion_screen.dart';
import '../features/guides/guide_step_screen.dart';
import '../features/guides/pre_visit_screen.dart';
import '../features/guides/service_detail_screen.dart';
import '../features/guides/service_list_screen.dart';
import '../features/home/home_screen.dart';
import '../features/language_select/language_select_screen.dart';
import '../features/online/online_screen.dart';
import 'routes.dart';
import 'theme.dart';

class CainApp extends StatelessWidget {
  final String initialRoute;

  const CainApp({super.key, this.initialRoute = AppRoutes.languageSelect});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cain',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: initialRoute,
      onGenerateRoute: _generateRoute,
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>? ?? {};

    switch (settings.name) {
      case AppRoutes.languageSelect:
        return _slide(const LanguageSelectScreen());

      case AppRoutes.home:
        return _slide(const HomeScreen());

      case AppRoutes.serviceList:
        return _slide(ServiceListScreen(categoryId: args['categoryId'] as String?));

      case AppRoutes.serviceDetail:
        return _slide(ServiceDetailScreen(serviceId: args['serviceId'] as String));

      case AppRoutes.preVisit:
        return _slide(PreVisitScreen(serviceId: args['serviceId'] as String));

      case AppRoutes.guideStep:
        return _slide(GuideStepScreen(
          serviceId: args['serviceId'] as String,
          stepIndex: args['stepIndex'] as int? ?? 0,
        ));

      case AppRoutes.completion:
        return _slide(CompletionScreen(serviceId: args['serviceId'] as String));

      // TODO(지도 보류): 지도 구현 후 아래 주석 해제 + import 복원
      // case AppRoutes.campus:
      //   return _slide(const CampusScreen());

      case AppRoutes.directory:
        return _slide(const DirectoryScreen());

      case AppRoutes.online:
        return _slide(const OnlineScreen());

      case AppRoutes.assistant:
        return _slide(AssistantScreen(
          serviceId: args['serviceId'] as String?,
          stepId: args['stepId'] as String?,
        ));

      // settings 라우트: 홈 탭 3번 인덱스(설정)로 이동하는 것이 기본.
      // 외부에서 직접 라우팅이 필요한 경우를 위해 홈으로 리다이렉트.
      case AppRoutes.settings:
        return _slide(const HomeScreen());

      default:
        return _slide(const HomeScreen());
    }
  }

  PageRoute _slide(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeInOut)),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}
