import 'package:flutter/material.dart';

/// Compiled design system for MyCampus.
///
/// `theme.md` is the product-facing source of truth. Keep changes to tokens,
/// typography, component states, and visual rules synchronized with that file.
abstract final class AppColors {
  static const primary = Color(0xFF475FB1);
  static const primaryHover = Color(0xFF5870C9);
  static const primaryPressed = Color(0xFF374A8C);
  static const primaryDisabled = Color(0x61475FB1);

  static const accent = Color(0xFFC9A24B);
  static const accentMuted = Color(0x26C9A24B);

  static const surface0 = Color(0xFF14151A);
  static const surface1 = Color(0xFF1B1C22);
  static const surface2 = Color(0xFF23252D);
  static const surface3 = Color(0xFF2C2E38);
  static const outline = Color(0xFF383A45);
  static const outlineSubtle = Color(0xFF2A2C34);

  static const textPrimary = Color(0xFFF3F4F6);
  static const textSecondary = Color(0xFFA6AAB6);
  static const textTertiary = Color(0xFF71747E);
  static const textDisabled = Color(0xFF54565F);

  static const success = Color(0xFF3BA55C);
  static const error = Color(0xFFED4245);
  static const warning = Color(0xFFFAA61A);
  static const info = Color(0xFF4A90E2);

  static const lightSurface0 = Color(0xFFF6F7FB);
  static const lightSurface1 = Color(0xFFFFFFFF);
  static const lightSurface2 = Color(0xFFF0F2F8);
  static const lightSurface3 = Color(0xFFE7EAF2);
  static const lightOutline = Color(0xFFD5D9E5);
  static const lightOutlineSubtle = Color(0xFFE5E8F0);
  static const lightTextPrimary = Color(0xFF171923);
  static const lightTextSecondary = Color(0xFF565B68);
  static const lightTextTertiary = Color(0xFF747A89);

  static const onPrimary = Color(0xFFFFFFFF);
  static const onAccent = Color(0xFF1B1C22);

  static Color get shadowTinted => primary.withValues(alpha: 0.18);
}

abstract final class AppGradients {
  static const hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF475FB1), Color(0xFF2E3B78)],
  );

  static const accentGlow = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC9A24B), Color(0xFF9C7A2F)],
  );
}

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

abstract final class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const pill = 999.0;
}

abstract final class AppMotion {
  static const fast = Duration(milliseconds: 120);
  static const normal = Duration(milliseconds: 200);
  static const slow = Duration(milliseconds: 320);
  static const standard = Curves.easeOutCubic;
  static const emphasized = Curves.easeInOutCubicEmphasized;
}

abstract final class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.lightSurface0,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.accent,
        onSecondary: AppColors.onAccent,
        surface: AppColors.lightSurface1,
        onSurface: AppColors.lightTextPrimary,
        error: AppColors.error,
        onError: AppColors.onPrimary,
        outline: AppColors.lightOutline,
      ),
    );
    final body = base.textTheme.apply(
      fontFamily: 'Inter',
      bodyColor: AppColors.lightTextSecondary,
      displayColor: AppColors.lightTextPrimary,
    );
    final textTheme = body.copyWith(
      displaySmall: body.displaySmall?.copyWith(
        fontFamily: 'Sora',
        color: AppColors.lightTextPrimary,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: body.headlineMedium?.copyWith(
        fontFamily: 'Sora',
        color: AppColors.lightTextPrimary,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: body.headlineSmall?.copyWith(
        fontFamily: 'Sora',
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.lightTextPrimary,
      ),
      titleLarge: body.titleLarge?.copyWith(
        fontFamily: 'Sora',
        fontWeight: FontWeight.w600,
        color: AppColors.lightTextPrimary,
      ),
      titleMedium: body.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.lightTextPrimary,
      ),
      bodyLarge: body.bodyLarge?.copyWith(
        color: AppColors.lightTextSecondary,
        height: 1.5,
      ),
      bodyMedium: body.bodyMedium?.copyWith(
        fontSize: 14,
        color: AppColors.lightTextSecondary,
        height: 1.5,
      ),
      labelLarge: body.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelSmall: body.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
        color: AppColors.lightTextTertiary,
      ),
    );
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: const BorderSide(color: AppColors.lightOutline),
    );

    return base.copyWith(
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: AppColors.lightSurface1,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.lightOutlineSubtle),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          animationDuration: AppMotion.normal,
          minimumSize: const WidgetStatePropertyAll(Size(48, 52)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
          foregroundColor: const WidgetStatePropertyAll(AppColors.onPrimary),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.primaryDisabled;
            }
            if (states.contains(WidgetState.pressed)) {
              return AppColors.primaryPressed;
            }
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.focused)) {
              return AppColors.primaryHover;
            }
            return AppColors.primary;
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          animationDuration: AppMotion.normal,
          minimumSize: const WidgetStatePropertyAll(Size(48, 52)),
          foregroundColor: const WidgetStatePropertyAll(
            AppColors.lightTextPrimary,
          ),
          side: const WidgetStatePropertyAll(
            BorderSide(color: AppColors.lightOutline),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size.square(48)),
          foregroundColor: const WidgetStatePropertyAll(
            AppColors.lightTextPrimary,
          ),
          backgroundColor: const WidgetStatePropertyAll(
            AppColors.lightSurface1,
          ),
          side: const WidgetStatePropertyAll(
            BorderSide(color: AppColors.lightOutlineSubtle),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.accentMuted,
        labelStyle: textTheme.labelSmall?.copyWith(
          color: const Color(0xFF735B1D),
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface1,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        labelStyle: const TextStyle(color: AppColors.lightTextSecondary),
        hintStyle: const TextStyle(color: AppColors.lightTextTertiary),
        prefixIconColor: AppColors.lightTextTertiary,
        suffixIconColor: AppColors.lightTextTertiary,
        border: inputBorder,
        enabledBorder: inputBorder,
        disabledBorder: inputBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.error, width: 1.4),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightOutlineSubtle,
        thickness: 1,
        space: AppSpacing.lg,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surface3,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: AppColors.primary.withValues(alpha: 0.24),
        selectionHandleColor: AppColors.primary,
      ),
    );
  }

  static ThemeData get dark {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.surface0,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.accent,
        onSecondary: AppColors.onAccent,
        surface: AppColors.surface1,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: AppColors.onPrimary,
        outline: AppColors.outline,
      ),
    );

    final body = base.textTheme.apply(
      fontFamily: 'Inter',
      bodyColor: AppColors.textSecondary,
      displayColor: AppColors.textPrimary,
    );
    final textTheme = body.copyWith(
      displaySmall: body.displaySmall?.copyWith(
        fontFamily: 'Sora',
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: body.headlineMedium?.copyWith(
        fontFamily: 'Sora',
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: body.headlineSmall?.copyWith(
        fontFamily: 'Sora',
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleLarge: body.titleLarge?.copyWith(
        fontFamily: 'Sora',
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleMedium: body.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: body.bodyLarge?.copyWith(
        color: AppColors.textSecondary,
        height: 1.5,
      ),
      bodyMedium: body.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
      ),
      labelLarge: body.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelSmall: body.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
        color: AppColors.textTertiary,
      ),
    );

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: const BorderSide(color: AppColors.outlineSubtle),
    );

    return base.copyWith(
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: AppColors.surface2,
        elevation: 0,
        shadowColor: AppColors.shadowTinted,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.outlineSubtle),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          animationDuration: AppMotion.normal,
          minimumSize: const WidgetStatePropertyAll(Size(48, 52)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md - AppSpacing.xs,
            ),
          ),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.primaryDisabled;
            }
            if (states.contains(WidgetState.pressed)) {
              return AppColors.primaryPressed;
            }
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.focused)) {
              return AppColors.primaryHover;
            }
            return AppColors.primary;
          }),
          foregroundColor: const WidgetStatePropertyAll(AppColors.onPrimary),
          overlayColor: WidgetStatePropertyAll(
            AppColors.onPrimary.withValues(alpha: 0.08),
          ),
          shadowColor: WidgetStatePropertyAll(AppColors.shadowTinted),
          elevation: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.pressed) ? 0 : 4,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          animationDuration: AppMotion.normal,
          minimumSize: const WidgetStatePropertyAll(Size(48, 52)),
          foregroundColor: const WidgetStatePropertyAll(AppColors.textPrimary),
          side: const WidgetStatePropertyAll(
            BorderSide(color: AppColors.outline),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size.square(48)),
          foregroundColor: const WidgetStatePropertyAll(AppColors.textPrimary),
          backgroundColor: const WidgetStatePropertyAll(AppColors.surface1),
          side: const WidgetStatePropertyAll(
            BorderSide(color: AppColors.outlineSubtle),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.accentMuted,
        labelStyle: textTheme.labelSmall?.copyWith(
          color: AppColors.accent,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface2,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textTertiary),
        prefixIconColor: AppColors.textTertiary,
        suffixIconColor: AppColors.textTertiary,
        border: inputBorder,
        enabledBorder: inputBorder,
        disabledBorder: inputBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.error, width: 1.4),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineSubtle,
        thickness: 1,
        space: AppSpacing.lg,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surface3,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: AppColors.primary.withValues(alpha: 0.32),
        selectionHandleColor: AppColors.primary,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.onPrimary,
      ),
      splashColor: AppColors.primary.withValues(alpha: 0.12),
      highlightColor: AppColors.primary.withValues(alpha: 0.08),
    );
  }
}
