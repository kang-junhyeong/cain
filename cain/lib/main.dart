import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_theme.dart';
import 'repositories/api_chat_repository.dart';
import 'repositories/building_repository.dart';
import 'repositories/chat_repository.dart';
import 'repositories/contact_repository.dart';
import 'repositories/demo_chat_repository.dart';
import 'repositories/local_service_repository.dart';
import 'repositories/service_repository.dart';
import 'screens/home_screen.dart';
import 'screens/language_select_screen.dart';
import 'services/chat_api_service.dart';
import 'viewmodels/locale_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  const apiBase = String.fromEnvironment('CAIN_API_BASE');
  final ServiceRepository serviceRepository = LocalServiceRepository();
  final ChatRepository chatRepository = apiBase.isEmpty
      ? DemoChatRepository(serviceRepository: serviceRepository)
      : ApiChatRepository(service: ChatApiService(baseUrl: apiBase));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()..load()),
        Provider<ServiceRepository>.value(value: serviceRepository),
        Provider<ContactRepository>.value(value: ContactRepository()),
        Provider<BuildingRepository>.value(value: BuildingRepository()),
        Provider<ChatRepository>.value(value: chatRepository),
      ],
      child: const CainApp(),
    ),
  );
}

class CainApp extends StatelessWidget {
  const CainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cain',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const _StartScreen(),
    );
  }
}

/// LocaleProvider 상태에 따라 첫 화면을 고른다.
/// 언어 선택이 끝나면 화면 이동 없이 이 위젯이 다시 그려져 홈으로 바뀐다.
class _StartScreen extends StatelessWidget {
  const _StartScreen();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LocaleProvider>();

    if (!provider.isLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return provider.hasSelected ? const HomeScreen() : const LanguageSelectScreen();
  }
}
