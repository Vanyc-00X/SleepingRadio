/// Громкость при fade-out: линейно от [baseVolume] к 0 за [fadeFor].
double computeFadeVolume({
  required Duration remaining,
  required Duration fadeFor,
  double baseVolume = 1,
}) {
  if (fadeFor <= Duration.zero) return 0;
  if (remaining <= Duration.zero) return 0;
  if (remaining >= fadeFor) return baseVolume;
  final t = remaining.inMilliseconds / fadeFor.inMilliseconds;
  return (baseVolume * t).clamp(0.0, 1.0);
}
