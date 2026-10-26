import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color kFallbackSeed = Color(0xFF8B7BF7);

/// Brand scheme used when the device has no wallpaper palette.
ColorScheme fallbackScheme(Brightness brightness) {
  return ColorScheme.fromSeed(
    seedColor: kFallbackSeed,
    brightness: brightness,
    dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
  );
}

ThemeData buildAppTheme({required ColorScheme scheme}) {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    brightness: scheme.brightness,
    scaffoldBackgroundColor: scheme.surface,
    splashFactory: InkSparkle.splashFactory,
    visualDensity: VisualDensity.standard,
    textTheme: _textTheme(scheme),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
      },
    ),
  );

  return base.copyWith(
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: 20,
      foregroundColor: scheme.onSurface,
      titleTextStyle: base.textTheme.titleLarge,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 56),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        textStyle: base.textTheme.labelLarge,
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
        foregroundColor: scheme.onSurface,
        textStyle: base.textTheme.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        foregroundColor: scheme.onSurfaceVariant,
        textStyle: base.textTheme.labelLarge,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(shape: const CircleBorder()),
    ),
    sliderTheme: base.sliderTheme.copyWith(
      trackHeight: 4,
      activeTrackColor: scheme.primary,
      inactiveTrackColor: scheme.surfaceContainerHighest,
      thumbColor: scheme.primary,
      overlayColor: scheme.primary.withValues(alpha: 0.12),
      valueIndicatorColor: scheme.primary,
      valueIndicatorTextStyle: base.textTheme.labelMedium?.copyWith(
        color: scheme.onPrimary,
      ),
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
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
      space: 24,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: base.textTheme.bodyMedium?.copyWith(
        color: scheme.onInverseSurface,
      ),
      actionTextColor: scheme.inversePrimary,
      shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(18)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      modalBackgroundColor: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: scheme.onSurfaceVariant.withValues(alpha: 0.4),
      shape: const RoundedSuperellipseBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
      shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(28)),
      titleTextStyle: base.textTheme.headlineSmall,
      contentTextStyle: base.textTheme.bodyMedium?.copyWith(
        color: scheme.onSurfaceVariant,
      ),
    ),
    cardTheme: CardThemeData(
      color: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(24)),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: scheme.onSurfaceVariant,
      textColor: scheme.onSurface,
      titleTextStyle: base.textTheme.titleMedium,
      subtitleTextStyle: base.textTheme.bodySmall?.copyWith(
        color: scheme.onSurfaceVariant,
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: scheme.primary,
      selectionColor: scheme.primary.withValues(alpha: 0.3),
      selectionHandleColor: scheme.primary,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: ShapeDecoration(
        color: scheme.inverseSurface,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textStyle: base.textTheme.bodySmall?.copyWith(
        color: scheme.onInverseSurface,
      ),
    ),
  );
}

/// System bar style that follows the active colour scheme in both brightnesses.
SystemUiOverlayStyle appOverlayStyle(ColorScheme scheme) {
  final isDark = scheme.brightness == Brightness.dark;
  final iconBrightness = isDark ? Brightness.light : Brightness.dark;
  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: iconBrightness,
    statusBarBrightness: scheme.brightness,
    systemNavigationBarColor: scheme.surface,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: iconBrightness,
  );
}

TextTheme _textTheme(ColorScheme scheme) {
  final typography = Typography.material2021(
    platform: TargetPlatform.android,
    colorScheme: scheme,
  );
  final text = scheme.brightness == Brightness.dark
      ? typography.white
      : typography.black;
  return text.copyWith(
    displayLarge: text.displayLarge?.copyWith(
      fontSize: 56,
      fontWeight: FontWeight.w300,
      letterSpacing: -1.8,
      height: 1.05,
    ),
    displayMedium: text.displayMedium?.copyWith(
      fontSize: 42,
      fontWeight: FontWeight.w300,
      letterSpacing: -1.2,
      height: 1.08,
    ),
    displaySmall: text.displaySmall?.copyWith(
      fontSize: 34,
      fontWeight: FontWeight.w300,
      letterSpacing: -0.8,
    ),
    headlineLarge: text.headlineLarge?.copyWith(
      fontSize: 32,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.8,
    ),
    headlineMedium: text.headlineMedium?.copyWith(
      fontSize: 26,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.4,
    ),
    headlineSmall: text.headlineSmall?.copyWith(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.2,
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
    titleSmall: text.titleSmall?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    ),
    bodyLarge: text.bodyLarge?.copyWith(fontSize: 16.5, height: 1.5),
    bodyMedium: text.bodyMedium?.copyWith(fontSize: 14.5, height: 1.45),
    bodySmall: text.bodySmall?.copyWith(fontSize: 12.5, height: 1.4),
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
