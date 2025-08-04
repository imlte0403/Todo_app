import 'package:flutter/material.dart';

// 커스텀 색상 클래스
class AppColors extends ThemeExtension<AppColors> {
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color success;
  final Color warning;
  final Color error;
  final Color background;
  final Color surface;
  final Color card;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;

  AppColors({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.success,
    required this.warning,
    required this.error,
    required this.background,
    required this.surface,
    required this.card,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
  });

  // 라이트 테마 색상
  static AppColors get light => AppColors(
    primary: const Color(0xFF6366F1), // 인디고
    secondary: const Color(0xFF8B5CF6), // 보라
    accent: const Color(0xFFF59E0B), // 주황
    success: const Color(0xFF10B981), // 초록
    warning: const Color(0xFFF59E0B), // 주황
    error: const Color(0xFFEF4444), // 빨강
    background: const Color(0xFFF8FAFC), // 연한 회색
    surface: Colors.white,
    card: const Color(0xFFF1F5F9), // 카드 배경
    textPrimary: const Color(0xFF1E293B), // 진한 회색
    textSecondary: const Color(0xFF64748B), // 중간 회색
    border: const Color(0xFFE2E8F0), // 테두리
  );

  // 다크 테마 색상 (향후 확장용)
  static AppColors get dark => AppColors(
    primary: const Color(0xFF818CF8),
    secondary: const Color(0xFFA78BFA),
    accent: const Color(0xFFFBBF24),
    success: const Color(0xFF34D399),
    warning: const Color(0xFFFBBF24),
    error: const Color(0xFFF87171),
    background: const Color(0xFF0F172A),
    surface: const Color(0xFF1E293B),
    card: const Color(0xFF334155),
    textPrimary: const Color(0xFFF1F5F9),
    textSecondary: const Color(0xFF94A3B8),
    border: const Color(0xFF475569),
  );

  @override
  ThemeExtension<AppColors> copyWith({
    Color? primary,
    Color? secondary,
    Color? accent,
    Color? success,
    Color? warning,
    Color? error,
    Color? background,
    Color? surface,
    Color? card,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      card: card ?? this.card,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      card: Color.lerp(card, other.card, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
    );
  }
}

// 앱 테마 클래스
class AppTheme {
  static ThemeData get lightTheme {
    final colors = AppColors.light;

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primary,
        brightness: Brightness.light,
      ),
      extensions: [colors],

      // 폰트 설정 (한글 지원)
      fontFamily: 'Apple SD Gothic Neo', // macOS 한글 폰트
      // 앱바 테마
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        titleTextStyle: TextStyle(
          color: colors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // 카드 테마
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 2,
        shadowColor: colors.textPrimary.withAlpha(26), // withOpacity(0.1)
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // 버튼 테마
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: colors.primary.withAlpha(77),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // 텍스트 필드 테마
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),

      // 스캐폴드 배경색
      scaffoldBackgroundColor: colors.background,
    );
  }
}
