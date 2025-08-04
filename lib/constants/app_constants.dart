class AppConstants {
  // 캐시 관련
  static const int maxCacheSize = 100;

  // 애니메이션 관련
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration checkAnimationDuration = Duration(milliseconds: 200);

  // UI 관련
  static const double defaultBorderRadius = 16.0;
  static const double smallBorderRadius = 12.0;
  static const double cardElevation = 2.0;
  static const double shadowBlurRadius = 10.0;

  // 색상 투명도
  static const double lightOpacity = 0.1;
  static const double mediumOpacity = 0.3;
  static const double shadowOpacity = 0.05;

  // 완료된 할 일 관련
  static const double completedCardOpacity = 0.7;
  static const double completedTagOpacity = 0.5;
  static const double completedTextOpacity = 0.6;

  // 날짜 관련
  static const int maxDaysInFuture = 365;
  static const int maxDaysInPast = 30;

  // 텍스트 관련
  static const double titleFontSize = 20.0;
  static const double bodyFontSize = 16.0;
  static const double captionFontSize = 12.0;
  static const double smallFontSize = 11.0;
}
