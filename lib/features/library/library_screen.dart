import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Библиотека'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.amber,
            labelColor: AppColors.amber,
            unselectedLabelColor: AppColors.mist,
            tabs: [
              Tab(text: 'Книги'),
              Tab(text: 'Выпуски'),
              Tab(text: 'Ссылки'),
              Tab(text: 'Избранное'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _EmptyLibraryTab(
              icon: Icons.menu_book_outlined,
              title: 'Книг пока нет',
              subtitle: 'Импорт .fb2 / .epub — этап 2',
            ),
            _EmptyLibraryTab(
              icon: Icons.podcasts_outlined,
              title: 'Выпусков пока нет',
              subtitle: 'Новости и подкасты появятся позже',
            ),
            _EmptyLibraryTab(
              icon: Icons.link_outlined,
              title: 'Ссылок пока нет',
              subtitle: 'URL Reader — этап 4',
            ),
            _EmptyLibraryTab(
              icon: Icons.favorite_border,
              title: 'Избранное пусто',
              subtitle: 'Отмечайте материалы звёздочкой',
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyLibraryTab extends StatelessWidget {
  const _EmptyLibraryTab({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.mist.withValues(alpha: 0.7)),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
