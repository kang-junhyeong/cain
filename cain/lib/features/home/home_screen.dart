import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../core/locale/locale_provider.dart';
import '../../core/models/service.dart';
import '../../core/repositories/service_repository.dart';
import '../../shared/widgets/service_card.dart';
import 'home_view_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;
  late final HomeViewModel _vm;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vm = HomeViewModel(ServiceRepository());
    _vm.loadFeatured();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: IndexedStack(
          index: _currentTab,
          children: [
            _HomeTab(vm: _vm, searchCtrl: _searchCtrl),
            _SearchTab(vm: _vm, searchCtrl: _searchCtrl),
            const _SettingsTab(),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
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
  final HomeViewModel vm;
  final TextEditingController searchCtrl;

  const _HomeTab({required this.vm, required this.searchCtrl});

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
                      const Row(
                        children: [
                          Text(
                            'Campus ',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary,
                            ),
                          ),
                          Text(
                            'Guide',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
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
                  color: AppTheme.primary.withValues(alpha: 0.15),
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
                onChanged: (v) => vm.search(v, locale),
                decoration: InputDecoration(
                  hintText: strings.searchHint,
                  prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                  suffixIcon: searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchCtrl.clear();
                            vm.clearSearch();
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
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.serviceList,
                        arguments: {'categoryId': 'documents'},
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
                    onTap: () => Navigator.pushNamed(context, AppRoutes.serviceList),
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
    Navigator.pushNamed(
      context,
      AppRoutes.serviceDetail,
      arguments: {'serviceId': service.id},
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
      onTap: () => Navigator.pushNamed(context, AppRoutes.assistant),
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
                color: AppTheme.accent.withValues(alpha: 0.12),
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
  final HomeViewModel vm;
  final TextEditingController searchCtrl;

  const _SearchTab({required this.vm, required this.searchCtrl});

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
              onChanged: (v) => vm.search(v, locale),
              decoration: InputDecoration(
                hintText: strings.searchHint,
                prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                suffixIcon: searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchCtrl.clear();
                          vm.clearSearch();
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
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.serviceDetail,
                        arguments: {'serviceId': vm.searchResults[i].id},
                      ),
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
}

// ───────────────────── 설정 탭 ─────────────────────
class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    // 설정 화면은 별도 파일에 구현되어 있으나 탭 내에서도 표시
    return Navigator(
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (_) => const _InlineSettingsView(),
      ),
    );
  }
}

class _InlineSettingsView extends StatelessWidget {
  const _InlineSettingsView();

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
