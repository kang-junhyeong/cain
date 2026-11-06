import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_theme.dart';
import '../app_strings.dart';
import '../viewmodels/locale_provider.dart';

// ignore_for_file: use_build_context_synchronously

// TODO(데이터 보류): 실제 한기대 공식 URL 확인 후 아래 _kServices 업데이트
// 현재 URL은 더미이며 실제 URL이 아님
const List<_OnlineServiceItem> _kServices = [
  _OnlineServiceItem(
    icon: Icons.laptop_mac,
    titleKo: '학과 홈페이지',
    titleEn: 'Department Website',
    titleZh: '学科主页',
    titleBn: 'বিভাগের ওয়েবসাইট',
    descKo: '학과 공지사항, 교수진, 주요 정보',
    descEn: 'Department notices, faculty, key info',
    descZh: '学科公告、教师信息、主要内容',
    descBn: 'বিভাগীয় বিজ্ঞপ্তি, শিক্ষকমণ্ডলী, মূল তথ্য',
    url: 'TODO: 실제 학과 홈페이지 URL',
  ),
  _OnlineServiceItem(
    icon: Icons.how_to_reg,
    titleKo: '수강신청',
    titleEn: 'Course Registration',
    titleZh: '选课申请',
    titleBn: 'কোর্স নিবন্ধন',
    descKo: '수강신청 및 수강변경',
    descEn: 'Register or change courses',
    descZh: '选课及更改课程',
    descBn: 'কোর্স নিবন্ধন বা পরিবর্তন',
    url: 'TODO: 실제 수강신청 URL',
  ),
  _OnlineServiceItem(
    icon: Icons.menu_book,
    titleKo: '강의계획서',
    titleEn: 'Syllabus',
    titleZh: '课程计划书',
    titleBn: 'সিলেবাস',
    descKo: '강의별 계획서 확인',
    descEn: 'Check syllabus by course',
    descZh: '按课程查看计划书',
    descBn: 'কোর্স অনুযায়ী সিলেবাস দেখুন',
    url: 'TODO: 실제 강의계획서 URL',
  ),
  _OnlineServiceItem(
    icon: Icons.school,
    titleKo: 'EL (e-Learning)',
    titleEn: 'EL (e-Learning)',
    titleZh: 'EL（网络学习）',
    titleBn: 'EL (ই-লার্নিং)',
    descKo: '온라인 강의, 과제, 출석 관리',
    descEn: 'Online lectures, assignments, attendance',
    descZh: '在线授课、作业、出勤管理',
    descBn: 'অনলাইন লেকচার, অ্যাসাইনমেন্ট, উপস্থিতি',
    url: 'TODO: 실제 EL URL',
  ),
];

class OnlineScreen extends StatelessWidget {
  const OnlineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale;
    final strings = AppStrings(locale);

    return Scaffold(
      appBar: AppBar(title: Text(strings.onlineTitle)),
      backgroundColor: AppTheme.background,
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _kServices.length,
        itemBuilder: (ctx, i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _OnlineCard(
            item: _kServices[i],
            locale: locale,
            strings: strings,
          ),
        ),
      ),
    );
  }
}

class _OnlineCard extends StatelessWidget {
  final _OnlineServiceItem item;
  final String locale;
  final AppStrings strings;

  const _OnlineCard({required this.item, required this.locale, required this.strings});

  @override
  Widget build(BuildContext context) {
    final title = item.titleFor(locale);
    final desc = item.descFor(locale);
    final hasUrl = !item.url.startsWith('TODO');

    return Container(
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
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: AppTheme.primary, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                if (!hasUrl) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(strings.urlPending, style: const TextStyle(fontSize: 11, color: AppTheme.warning)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (hasUrl)
            ElevatedButton(
              onPressed: () => _open(context, item.url),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(60, 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                textStyle: const TextStyle(fontSize: 13),
              ),
              child: Text(strings.openLink),
            ),
        ],
      ),
    );
  }

  Future<void> _open(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        final locale = context.read<LocaleProvider>().locale;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings(locale).cannotOpenLink)),
        );
      }
    }
  }
}

class _OnlineServiceItem {
  final IconData icon;
  final String titleKo, titleEn, titleZh, titleBn;
  final String descKo, descEn, descZh, descBn;
  final String url;

  const _OnlineServiceItem({
    required this.icon,
    required this.titleKo, required this.titleEn, required this.titleZh, required this.titleBn,
    required this.descKo, required this.descEn, required this.descZh, required this.descBn,
    required this.url,
  });

  String titleFor(String locale) {
    switch (locale) {
      case 'ko': return titleKo;
      case 'en': return titleEn;
      case 'zh': return titleZh;
      case 'bn': return titleBn;
      default: return titleEn;
    }
  }

  String descFor(String locale) {
    switch (locale) {
      case 'ko': return descKo;
      case 'en': return descEn;
      case 'zh': return descZh;
      case 'bn': return descBn;
      default: return descEn;
    }
  }
}
