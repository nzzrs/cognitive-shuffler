import 'package:flutter/material.dart';

const Color kFallbackSeed = Color(0xFF8B7BF7);

ThemeData buildAppTheme({required Color seed, required Brightness brightness}) {
  var scheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: brightness,
    dynamicSchemeVariant: DynamicSchemeVariant.expressive,
  );

  if (brightness == Brightness.dark) {
    // A quiet, true-dark canvas: dynamic colour still drives accents, while the
    // large surfaces stay near-black for OLED screens and low light.
    scheme = scheme.copyWith(
      surface: const Color(0xFF0A0A0D),
      surfaceDim: const Color(0xFF070709),
      surfaceBright: const Color(0xFF25252B),
      surfaceContainerLowest: const Color(0xFF070709),
      surfaceContainerLow: const Color(0xFF101014),
      surfaceContainer: const Color(0xFF15151A),
      surfaceContainerHigh: const Color(0xFF1B1B21),
      surfaceContainerHighest: const Color(0xFF222229),
      onSurface: const Color(0xFFEDEAF4),
      onSurfaceVariant: const Color(0xFFBBB6C8),
      outline: const Color(0xFF4A4756),
      outlineVariant: const Color(0xFF2C2A35),
    );
  }

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    brightness: brightness,
    scaffoldBackgroundColor: scheme.surface,
    splashFactory: InkSparkle.splashFactory,
    visualDensity: VisualDensity.standard,
    textTheme: _textTheme(brightness),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
      },
    ),
  );

  return base.copyWith(
    textTheme: base.textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: 20,
      foregroundColor: scheme.onSurface,
      titleTextStyle: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: -0.2,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 56),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        textStyle: base.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(60, 52),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        foregroundColor: scheme.onSurfaceVariant,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: scheme.onSurfaceVariant,
        shape: const CircleBorder(),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      shape: const StadiumBorder(),
      side: BorderSide(color: scheme.outlineVariant),
      backgroundColor: scheme.surfaceContainerLow,
      selectedColor: scheme.primaryContainer,
      labelStyle: base.textTheme.labelLarge?.copyWith(color: scheme.onSurface),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      showCheckmark: false,
    ),
    sliderTheme: base.sliderTheme.copyWith(
      trackHeight: 3,
      activeTrackColor: scheme.primary,
      inactiveTrackColor: scheme.surfaceContainerHighest,
      thumbColor: scheme.primary,
      overlayColor: scheme.primary.withValues(alpha: 0.12),
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? scheme.onPrimary
            : scheme.outline,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? scheme.primary
            : scheme.surfaceContainerHighest,
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? Colors.transparent
            : scheme.outlineVariant,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant.withValues(alpha: 0.6),
      thickness: 1,
      space: 32,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.surfaceContainerHigh,
      contentTextStyle: base.textTheme.bodyMedium?.copyWith(
        color: scheme.onSurface,
      ),
      shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(18)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      shape: const RoundedSuperellipseBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
    ),
  );
}

TextTheme _textTheme(Brightness brightness) {
  final base = Typography.material2021(
    platform: TargetPlatform.android,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kFallbackSeed,
      brightness: brightness,
    ),
  ).black;
  final text = brightness == Brightness.dark
      ? base.apply(
          bodyColor: const Color(0xFFEDEAF4),
          displayColor: const Color(0xFFEDEAF4),
        )
      : base;
  return text.copyWith(
    displayLarge: text.displayLarge?.copyWith(
      fontSize: 64,
      fontWeight: FontWeight.w300,
      letterSpacing: -2.2,
      height: 1.05,
    ),
    displayMedium: text.displayMedium?.copyWith(
      fontSize: 46,
      fontWeight: FontWeight.w300,
      letterSpacing: -1.6,
      height: 1.08,
    ),
    headlineLarge: text.headlineLarge?.copyWith(
      fontSize: 34,
      fontWeight: FontWeight.w400,
      letterSpacing: -1,
    ),
    headlineMedium: text.headlineMedium?.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.6,
    ),
    titleLarge: text.titleLarge?.copyWith(
      fontSize: 21,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.2,
    ),
    titleMedium: text.titleMedium?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    bodyLarge: text.bodyLarge?.copyWith(fontSize: 16.5, height: 1.5),
    bodyMedium: text.bodyMedium?.copyWith(fontSize: 14.5, height: 1.45),
    labelLarge: text.labelLarge?.copyWith(
      fontSize: 14.5,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    ),
    labelMedium: text.labelMedium?.copyWith(
      fontSize: 12.5,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.4,
    ),
  );
}
