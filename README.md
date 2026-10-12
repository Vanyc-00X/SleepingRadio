# Сонный радиоприёмник

Ночное аудиоприложение: спокойным голосом читает книги, новости и ссылки, собирает мягкие выпуски и гасит звук по таймеру сна.

Полное ТЗ: [`docs/TZ.md`](docs/TZ.md)  
План этапов: [`docs/STAGES.md`](docs/STAGES.md)

## Стек

- Flutter (Android first, iOS в том же проекте)
- Riverpod + go_router
- Drift / SQLite
- Далее: `just_audio` + `audio_service`, облачный TTS/LLM

## Запуск

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Текущий статус

**Этап 0 — Foundation** завершён: каркас, тема, навигация, модели, БД, сохраняемые настройки.

Следующий: **Этап 1 — Плеер и таймер сна**.
