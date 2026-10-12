abstract final class AppConstants {
  static const String appName = 'Сонный радиоприёмник';
  static const String appNameShort = 'Сонное радио';

  static const List<int> timerPresetsMinutes = [15, 30, 45, 60, 90];
  static const int fadeOutSecondsMin = 30;
  static const int fadeOutSecondsMax = 60;
  static const int timerExtendMinutes = 15;

  static const double speechRateMin = 0.8;
  static const double speechRateMax = 1.5;

  static const List<({String id, String label})> mvpVoices = [
    (id: 'calm_female_ru', label: 'Спокойный женский'),
    (id: 'warm_male_ru', label: 'Тёплый мужской'),
  ];
}
