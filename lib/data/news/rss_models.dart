class RssItem {
  const RssItem({
    required this.title,
    required this.summary,
    this.link,
    this.publishedAt,
  });

  final String title;
  final String summary;
  final String? link;
  final DateTime? publishedAt;
}

class RssFeed {
  const RssFeed({
    required this.title,
    required this.items,
  });

  final String title;
  final List<RssItem> items;
}
