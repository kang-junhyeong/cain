import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../app_strings.dart';
import '../viewmodels/locale_provider.dart';
import '../models/service.dart';
import '../repositories/service_repository.dart';
import '../widgets/service_card.dart';
import 'assistant_screen.dart';
import 'service_detail_screen.dart';
import 'service_list_screen.dart';
import '../viewmodels/home_view_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeViewModel(repository: context.read<ServiceRepository>())..loadFeatured(),
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: IndexedStack(
          index: _currentTab,
          children: [
            _HomeTab(searchCtrl: _searchCtrl),
            _SearchTab(searchCtrl: _searchCtrl, onGoHome: _goHomeTab),
            const _SettingsTab(),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  void _goHomeTab() {
    if (mounted) setState(() => _currentTab = 0);
  }

  Widget _buildBottomNav() {
    final strings = AppStrings(context.watch<LocaleProvider>().locale);
    return BottomNavigationBar(
      currentIndex: _currentTab,
      onTap: (i) => setState(() => _currentTab = i),
      items: [
        BottomNavigationBarItem(icon: const Icon(Icons.home_outlined), activeIcon: const Icon(Icons.home), label: strings.tabHome),
        BottomNavigationBarItem(icon: const Icon(Icons.search), label: strings.tabSearch),
        BottomNavigationBarItem(icon: const Icon(Icons.settings_outlined), activeIcon: const Icon(Icons.settings), label: strings.tabSettings),
      ],
    );
  }
}

// ───────────────────── 홈 탭 ─────────────────────
class _HomeTab extends StatelessWidget {
  final TextEditingController searchCtrl;

  const _HomeTab({required this.searchCtrl});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale;
    final strings = AppStrings(locale);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // 앱바
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.appName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                        ),
                      ),
                      Text(
                        strings.appSubtitle,
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // 언어 전환 버튼
                  _LocaleSwitcher(),
                ],
              ),
            ),
          ),

          // 배너 이미지
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 140,
                  color: AppTheme.primary.withOpacity(0.15),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_balance, size: 48, color: AppTheme.primary),
                        SizedBox(height: 8),
                        Text('한국기술교육대학교', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 검색바
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: TextField(
                controller: searchCtrl,
                onChanged: (v) => context.read<HomeViewModel>().search(v, locale),
                decoration: InputDecoration(
                  hintText: strings.searchHint,
                  prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                  suffixIcon: searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchCtrl.clear();
                            context.read<HomeViewModel>().clearSearch();
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),

          // 카테고리 버튼
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _CategoryButton(
                      icon: Icons.description,
                      label: strings.categoryDocuments,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ServiceListScreen(categoryId: 'documents'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CategoryButton(
                      icon: Icons.map_outlined,
                      label: strings.categoryCampus,
                      onTap: () {
                        // TODO(지도 보류): 지도 화면 구현 후 라우트 연결
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(strings.mapComingSoon)),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 주요 서비스
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    strings.featuredServices,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ServiceListScreen()),
                    ),
                    child: Text(
                      strings.viewAll,
                      style: const TextStyle(fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 서비스 카드 목록
          Consumer<HomeViewModel>(
            builder: (context, vm, _) {
              if (vm.isLoading) {
                return const SliverToBoxAdapter(
                  child: Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
                );
              }
              if (vm.isSearching) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child: ServiceCard(
                        service: vm.searchResults[i],
                        locale: locale,
                        onTap: () => _openDetail(context, vm.searchResults[i]),
                      ),
                    ),
                    childCount: vm.searchResults.length,
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: ServiceCard(
                      service: vm.featured[i],
                      locale: locale,
                      onTap: () => _openDetail(context, vm.featured[i]),
                    ),
                  ),
                  childCount: vm.featured.length,
                ),
              );
            },
          ),

          // 도움 기능
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Text(
                strings.helpSection,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: _AiAssistantCard(strings: strings),
            ),
          ),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context, ServiceModel service) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ServiceDetailScreen(serviceId: service.id)),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CategoryButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primary, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiAssistantCard extends StatelessWidget {
  final AppStrings strings;

  const _AiAssistantCard({required this.strings});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AssistantScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.smart_toy, color: AppTheme.accent, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.aiAssistant,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    strings.aiAssistantDesc,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}

// ───────────────────── 검색 탭 ─────────────────────
class _SearchTab extends StatelessWidget {
  final TextEditingController searchCtrl;
  final VoidCallback onGoHome;

  const _SearchTab({required this.searchCtrl, required this.onGoHome});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale;
    final strings = AppStrings(locale);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: TextField(
              controller: searchCtrl,
              autofocus: false,
              onChanged: (v) => context.read<HomeViewModel>().search(v, locale),
              decoration: InputDecoration(
                hintText: strings.searchHint,
                prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                suffixIcon: searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchCtrl.clear();
                          context.read<HomeViewModel>().clearSearch();
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: Consumer<HomeViewModel>(
              builder: (context, vm, _) {
                if (!vm.isSearching) {
                  return Center(
                    child: Text(strings.searchHint, style: const TextStyle(color: AppTheme.textSecondary)),
                  );
                }
                if (vm.searchResults.isEmpty) {
                  return Center(
                    child: Text(strings.noData, style: const TextStyle(color: AppTheme.textSecondary)),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: vm.searchResults.length,
                  itemBuilder: (ctx, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ServiceCard(
                      service: vm.searchResults[i],
                      locale: locale,
                      onTap: () => _openDetail(context, vm.searchResults[i]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 'home' 결과를 받으면 검색 탭에서 홈 탭으로 돌아간다.
  Future<void> _openDetail(BuildContext context, ServiceModel service) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => ServiceDetailScreen(serviceId: service.id)),
    );
    if (result == 'home') onGoHome();
  }
}

// ───────────────────── 설정 탭 ─────────────────────
class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale;
    final strings = AppStrings(locale);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Text(strings.settingsTitle,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          ),
          // 언어 섹션
          _SettingsSectionHeader(title: strings.languageSection),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: kSupportedLocales.map((loc) {
                final isSelected = locale == loc.code;
                return ListTile(
                  leading: Text(loc.flag, style: const TextStyle(fontSize: 24)),
                  title: Text(loc.label, style: TextStyle(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400)),
                  trailing: isSelected ? const Icon(Icons.check_circle, color: AppTheme.primary) : null,
                  onTap: () => context.read<LocaleProvider>().setLocale(loc.code),
                );
              }).toList(),
            ),
          ),
          const Divider(),
          _SettingsSectionHeader(title: strings.dataVersion),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text('2026.11.03.1', style: TextStyle(color: AppTheme.textSecondary)),
          ),
        ],
      ),
    );
  }
}

class _SettingsSectionHeader extends StatelessWidget {
  final String title;
  const _SettingsSectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
      ),
    );
  }
}

// ───────────────────── 언어 전환 위젯 ─────────────────────
class _LocaleSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LocaleProvider>();
    final current = kSupportedLocales.firstWhere((l) => l.code == provider.locale);

    return GestureDetector(
      onTap: () => _showPicker(context, provider),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.divider),
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(current.flag),
            const SizedBox(width: 6),
            Text(
              current.label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context, LocaleProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: kSupportedLocales.map((loc) {
            return ListTile(
              leading: Text(loc.flag, style: const TextStyle(fontSize: 24)),
              title: Text(loc.label),
              trailing: provider.locale == loc.code ? const Icon(Icons.check, color: AppTheme.primary) : null,
              onTap: () {
                provider.setLocale(loc.code);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
