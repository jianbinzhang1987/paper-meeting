import 'package:flutter/material.dart';

@immutable
class MeetingPalette extends ThemeExtension<MeetingPalette> {
  const MeetingPalette({
    required this.chrome,
    required this.chromeMuted,
    required this.pageBackground,
    required this.panelBackground,
    required this.panelBorder,
    required this.panelShadow,
    required this.accent,
    required this.accentSoft,
    required this.success,
    required this.warning,
    required this.danger,
    required this.textPrimary,
    required this.textSecondary,
    required this.textOnChrome,
  });

  final Color chrome;
  final Color chromeMuted;
  final Color pageBackground;
  final Color panelBackground;
  final Color panelBorder;
  final Color panelShadow;
  final Color accent;
  final Color accentSoft;
  final Color success;
  final Color warning;
  final Color danger;
  final Color textPrimary;
  final Color textSecondary;
  final Color textOnChrome;

  static const light = MeetingPalette(
    chrome: Color(0xFF0F3A67),
    chromeMuted: Color(0xFF15508A),
    pageBackground: Color(0xFFF5F7FA),
    panelBackground: Color(0xFFFFFFFF),
    panelBorder: Color(0xFFD9E1EC),
    panelShadow: Color(0x0A1677FF),
    accent: Color(0xFF1677FF),
    accentSoft: Color(0xFFE8F3FF),
    success: Color(0xFF52C41A),
    warning: Color(0xFFFAAD14),
    danger: Color(0xFFF53F3F),
    textPrimary: Color(0xFF1F2329),
    textSecondary: Color(0xFF4E5969),
    textOnChrome: Color(0xFFF7FAFC),
  );

  static const dark = MeetingPalette(
    chrome: Color(0xFF0E1C2C),
    chromeMuted: Color(0xFF13283D),
    pageBackground: Color(0xFF0D1622),
    panelBackground: Color(0xFF162230),
    panelBorder: Color(0xFF26384A),
    panelShadow: Color(0x22000000),
    accent: Color(0xFF68A8FF),
    accentSoft: Color(0xFF1E3550),
    success: Color(0xFF52B788),
    warning: Color(0xFFE2B45B),
    danger: Color(0xFFF07178),
    textPrimary: Color(0xFFF0F5FA),
    textSecondary: Color(0xFF9FB0C2),
    textOnChrome: Color(0xFFF7FAFC),
  );

  @override
  MeetingPalette copyWith({
    Color? chrome,
    Color? chromeMuted,
    Color? pageBackground,
    Color? panelBackground,
    Color? panelBorder,
    Color? panelShadow,
    Color? accent,
    Color? accentSoft,
    Color? success,
    Color? warning,
    Color? danger,
    Color? textPrimary,
    Color? textSecondary,
    Color? textOnChrome,
  }) {
    return MeetingPalette(
      chrome: chrome ?? this.chrome,
      chromeMuted: chromeMuted ?? this.chromeMuted,
      pageBackground: pageBackground ?? this.pageBackground,
      panelBackground: panelBackground ?? this.panelBackground,
      panelBorder: panelBorder ?? this.panelBorder,
      panelShadow: panelShadow ?? this.panelShadow,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textOnChrome: textOnChrome ?? this.textOnChrome,
    );
  }

  @override
  MeetingPalette lerp(ThemeExtension<MeetingPalette>? other, double t) {
    if (other is! MeetingPalette) return this;
    return MeetingPalette(
      chrome: Color.lerp(chrome, other.chrome, t) ?? chrome,
      chromeMuted: Color.lerp(chromeMuted, other.chromeMuted, t) ?? chromeMuted,
      pageBackground: Color.lerp(pageBackground, other.pageBackground, t) ?? pageBackground,
      panelBackground: Color.lerp(panelBackground, other.panelBackground, t) ?? panelBackground,
      panelBorder: Color.lerp(panelBorder, other.panelBorder, t) ?? panelBorder,
      panelShadow: Color.lerp(panelShadow, other.panelShadow, t) ?? panelShadow,
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t) ?? accentSoft,
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      danger: Color.lerp(danger, other.danger, t) ?? danger,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textOnChrome: Color.lerp(textOnChrome, other.textOnChrome, t) ?? textOnChrome,
    );
  }
}

class MeetingTheme {
  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final palette = brightness == Brightness.dark ? MeetingPalette.dark : MeetingPalette.light;
    final scheme = ColorScheme.fromSeed(
      seedColor: palette.accent,
      brightness: brightness,
      primary: palette.accent,
      surface: palette.panelBackground,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: palette.pageBackground,
    );

    final textTheme = base.textTheme.apply(
      bodyColor: palette.textPrimary,
      displayColor: palette.textPrimary,
    ).copyWith(
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 32,
        height: 1.15,
      ),
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 24,
        height: 1.2,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 22,
        height: 1.25,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 18,
        height: 1.3,
      ),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(
        fontSize: 15,
        height: 1.5,
        color: palette.textPrimary,
      ),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        fontSize: 14,
        height: 1.45,
        color: palette.textPrimary,
      ),
      bodySmall: base.textTheme.bodySmall?.copyWith(
        fontSize: 13,
        height: 1.4,
        color: palette.textSecondary,
      ),
      labelLarge: base.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );

    return base.copyWith(
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[palette],
      dividerColor: palette.panelBorder,
      cardTheme: CardThemeData(
        color: palette.panelBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: palette.panelBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: palette.pageBackground,
        foregroundColor: palette.textPrimary,
        titleTextStyle: textTheme.titleLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.dark ? const Color(0xFF101B28) : const Color(0xFFFFFFFF),
        hintStyle: TextStyle(color: palette.textSecondary),
        labelStyle: TextStyle(color: palette.textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: palette.panelBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: palette.panelBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: palette.accent, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: textTheme.labelLarge,
          backgroundColor: palette.accent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          side: BorderSide(color: palette.panelBorder),
          textStyle: textTheme.labelLarge,
          foregroundColor: palette.textPrimary,
          backgroundColor: brightness == Brightness.dark ? const Color(0xFF182535) : Colors.white,
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        side: BorderSide(color: palette.panelBorder),
        backgroundColor: brightness == Brightness.dark ? const Color(0xFF122232) : const Color(0xFFF7FAFC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: textTheme.bodySmall?.copyWith(color: palette.textPrimary),
      ),
      listTileTheme: ListTileThemeData(
        dense: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        iconColor: palette.textSecondary,
        textColor: palette.textPrimary,
      ),
    );
  }
}

extension MeetingThemeX on BuildContext {
  MeetingPalette get meetingPalette => Theme.of(this).extension<MeetingPalette>() ?? MeetingPalette.light;
}
