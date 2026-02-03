import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pengespareapp/l10n/app_localizations.dart';
import 'package:pengespareapp/src/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:pengespareapp/src/features/products/presentation/pages/product_list_page.dart';
import 'package:pengespareapp/src/features/settings/presentation/pages/settings_page.dart';
import 'package:pengespareapp/src/features/archive/presentation/pages/archive_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const ProductListPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: _currentIndex == 1
          ? null
          : AppBar(
              title: Text(
                _currentIndex == 0 ? l10n.dashboard : l10n.settings,
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.archive_outlined),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ArchivePage(),
                      ),
                    );
                  },
                  tooltip: l10n.archive,
                ),
              ],
            ),
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: l10n.dashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.shopping_bag_outlined),
            selectedIcon: const Icon(Icons.shopping_bag),
            label: l10n.products,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }
}
