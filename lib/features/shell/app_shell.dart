import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import 'mini_player_bar.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayerBar(),
          NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: navigationShell.goBranch,
            height: 68,
            backgroundColor: AppColors.nightElevated,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.nightlight_round_outlined, size: 26),
                selectedIcon: Icon(Icons.nightlight_round, size: 26),
                label: 'Домой',
                tooltip: 'Домой',
              ),
              NavigationDestination(
                icon: Icon(Icons.library_books_outlined, size: 26),
                selectedIcon: Icon(Icons.library_books, size: 26),
                label: 'Библиотека',
                tooltip: 'Библиотека',
              ),
              NavigationDestination(
                icon: Icon(Icons.play_circle_outline, size: 26),
                selectedIcon: Icon(Icons.play_circle, size: 26),
                label: 'Плеер',
                tooltip: 'Плеер',
              ),
              NavigationDestination(
                icon: Icon(Icons.tune_outlined, size: 26),
                selectedIcon: Icon(Icons.tune, size: 26),
                label: 'Настройки',
                tooltip: 'Настройки',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
