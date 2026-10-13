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

**Этап 8 — v1.2** готов: ambient под голосом, Ollama для комментариев, рекомендации тем, экспорт/импорт настроек.

Все этапы плана 0–8 закрыты по функционалу в `docs/STAGES.md`.

Облачный ключ: Настройки → TTS API key, или `--dart-define=TTS_API_KEY=...`  
Offline TTS: Piper; Ollama: Настройки → локальный ИИ; Ambient: переключатель в настройках.
