class NetworkPrivacyItem {
  const NetworkPrivacyItem({
    required this.title,
    required this.detail,
    required this.whenEnabled,
  });

  final String title;
  final String detail;
  final bool whenEnabled;
}

abstract final class NetworkPrivacyCatalog {
  static const items = <NetworkPrivacyItem>[
    NetworkPrivacyItem(
      title: 'Фрагменты текста для озвучки',
      detail:
          'В облачный TTS уходят короткие чанки (обычно до ~280 символов), '
          'а не файл книги целиком.',
      whenEnabled: true,
    ),
    NetworkPrivacyItem(
      title: 'Выбранный голос и скорость',
      detail: 'Идентификатор голоса и параметры синтеза передаются провайдеру TTS.',
      whenEnabled: true,
    ),
    NetworkPrivacyItem(
      title: 'Новости и статьи по URL',
      detail:
          'Для новостей/ссылок нужны сетевые запросы к источникам и LLM '
          '(этапы 4–5). Книги по умолчанию остаются на устройстве.',
      whenEnabled: true,
    ),
    NetworkPrivacyItem(
      title: 'Локальный кэш аудио',
      detail:
          'Уже синтезированные чанки хранятся на устройстве и повторно '
          'в сеть не отправляются.',
      whenEnabled: false,
    ),
    NetworkPrivacyItem(
      title: 'Системный TTS (fallback)',
      detail:
          'Если облако выключено или недоступно — озвучка идёт локальным '
          'движком ОС, текст наружу не уходит.',
      whenEnabled: false,
    ),
    NetworkPrivacyItem(
      title: 'Гоблин через ComfyUI',
      detail:
          'Чанки текста уходят только на ваш ПК по локальной сети '
          '(не в облако). Нужен запущенный ComfyUI с клоном голоса.',
      whenEnabled: false,
    ),
    NetworkPrivacyItem(
      title: 'Offline Piper (Ирина / Руслан)',
      detail:
          'Модель скачивается один раз, дальше озвучка полностью на телефоне '
          'без сети.',
      whenEnabled: false,
    ),
  ];
}
