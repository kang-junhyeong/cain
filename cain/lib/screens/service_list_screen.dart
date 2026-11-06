import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../app_strings.dart';
import '../viewmodels/locale_provider.dart';
import '../models/service.dart';
import '../repositories/service_repository.dart';
import '../widgets/service_card.dart';
import 'service_detail_screen.dart';

class ServiceListScreen extends StatefulWidget {
  final String? categoryId;

  const ServiceListScreen({super.key, this.categoryId});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  final _repo = ServiceRepository();
  List<ServiceModel> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    if (widget.categoryId != null) {
      _services = await _repo.getByCategory(widget.categoryId!);
    } else {
      _services = await _repo.getAll();
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale;
    final strings = AppStrings(locale);

    String title;
    if (widget.categoryId == 'documents') {
      title = strings.categoryDocuments;
    } else {
      title = strings.featuredServices;
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      backgroundColor: AppTheme.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.touch_app, color: AppTheme.primary, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          strings.selectService,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: _services.length,
                    itemBuilder: (ctx, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ServiceCard(
                        service: _services[i],
                        locale: locale,
                        onTap: () => _openDetail(_services[i].id),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _openDetail(String serviceId) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => ServiceDetailScreen(serviceId: serviceId)),
    );
    if (!mounted) return;
    if (result == 'home') Navigator.pop(context, 'home');
  }
}
