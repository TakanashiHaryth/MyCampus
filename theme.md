import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ============================================================
/// DESIGN TOKENS
/// ============================================================
class AppColors {
  AppColors._();

  // Primary — blurple/indigo, dari input user
  static const Color primary = Color(0xFF475FB1);
  static const Color primaryHover = Color(0xFF5870C9);
  static const Color primaryPressed = Color(0xFF374A8C);
  static const Color primaryDisabled = Color(0x61475FB1);

  // Accent — gold/champagne. Indigo + gold = kombinasi "premium" klasik
  // (fintech card, luxury branding). Guna SIKIT sahaja — untuk badge,
  // highlight, atau satu CTA istimewa. Kalau accent ni jadi warna kedua
  // yang dominan, "elegant" akan bertukar jadi "bercelaru".
  static const Color accent = Color(0xFFC9A24B);
  static const Color accentMuted = Color(0x26C9A24B); // 15% — bg highlight

  // Neutral scale — 4 lapisan untuk depth/elevation (bukan flat single dark)
  static const Color surface0 = Color(0xFF14151A); // scaffold background
  static const Color surface1 = Color(0xFF1B1C22); // card/base surface
  static const Color surface2 = Color(0xFF23252D); // elevated card
  static const Color surface3 = Color(0xFF2C2E38); // modal/overlay/sheet
  static const Color outline = Color(0xFF383A45);
  static const Color outlineSubtle = Color(0xFF2A2C34);

  // Text
  static const Color textPrimary = Color(0xFFF3F4F6);
  static const Color textSecondary = Color(0xFFA6AAB6);
  static const Color textTertiary = Color(0xFF71747E);
  static const Color textDisabled = Color(0xFF54565F);

  // Semantic
  static const Color success = Color(0xFF3BA55C);
  static const Color error = Color(0xFFED4245);
  static const Color warning = Color(0xFFFAA61A);

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onAccent = Color(0xFF1B1C22);

  // Shadow bertint primary — bukan hitam pekat. Ini yang bagi kesan
  // "elegant/soft glow" pada card & button, bukan shadow generic Material.
  static Color shadowTinted = primary.withValues(alpha: 0.18);
}

class AppGradients {
  AppGradients._();

  /// Signature gradient — SATU je tempat guna ni (hero card / CTA utama /
  /// app bar). Jangan sebar pada semua button, nanti hilang kesan "istimewa".
  static const LinearGradient hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF475FB1), Color(0xFF2E3B78)],
  );

  static const LinearGradient accentGlow = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC9A24B), Color(0xFF9C7A2F)],
  );
}

class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class AppRadius {
  AppRadius._();
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double pill = 999;
}

class AppMotion {
  AppMotion._();
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 320);
  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;
}

/// ============================================================
/// THEME
/// ============================================================
class AppTheme {
  AppTheme._();

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

    // Pairing 2 font — display (Sora, untuk headline: ada karakter/lebih
    // "elegant" dari sans generik) + body (Inter, sangat legible untuk
    // paragraf/label kecil). Guna SATU family je untuk semua text jadi
    // terasa flat/tak "designed" — ni titik yang paling ubah persepsi
    // "professional" sebenarnya, bukan warna.
    final display = GoogleFonts.soraTextTheme(base.textTheme);
    final body = GoogleFonts.interTextTheme(base.textTheme);

    final textTheme = body.copyWith(
      displaySmall: display.displaySmall?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: display.headlineMedium?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: display.headlineSmall?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
        color: AppColors.textTertiary,
      ),
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
          side: const BorderSide(color: AppColors.outlineSubtle, width: 1),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          animationDuration: AppMotion.normal,
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm + 4,
            ),
          ),
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
          foregroundColor: WidgetStateProperty.all(AppColors.onPrimary),
          overlayColor: WidgetStateProperty.all(
            AppColors.onPrimary.withValues(alpha: 0.08),
          ),
          shadowColor: WidgetStateProperty.all(AppColors.shadowTinted),
          elevation: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) return 0;
            return 4; // shadow tinted primary — bukan default black
          }),
        ),
      ),

      // Chip untuk badge/tag elegant guna accent gold — dipakai jarang²
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.accentMuted,
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.accent,
        ),
        side: const BorderSide(color: Colors.transparent),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),

      splashColor: AppColors.primary.withValues(alpha: 0.12),
      highlightColor: AppColors.primary.withValues(alpha: 0.08),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.outlineSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.outlineSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.outlineSubtle,
        thickness: 1,
        space: AppSpacing.lg,
      ),
    );
  }
}

/// ============================================================
/// CONTOH — hero card guna gradient signature (buang bila copy ke project)
/// ============================================================
///
/// Container(
///   padding: const EdgeInsets.all(AppSpacing.lg),
///   decoration: BoxDecoration(
///     gradient: AppGradients.hero,
///     borderRadius: BorderRadius.circular(AppRadius.lg),
///     boxShadow: [
///       BoxShadow(
///         color: AppColors.shadowTinted,
///         blurRadius: 24,
///         offset: const Offset(0, 8),
///       ),
///     ],
///   ),
///   child: Text('Upgrade to Pro', style: TextStyle(
///     fontFamily: GoogleFonts.sora().fontFamily,
///     fontSize: 20,
///     fontWeight: FontWeight.w600,
///     color: Colors.white,
///   )),
/// )
///
/// Button dengan micro-animation "scale" bila ditekan:
///
/// class AnimatedPressButton extends StatefulWidget {
///   final Widget child;
///   final VoidCallback onPressed;
///   const AnimatedPressButton({super.key, required this.child, required this.onPressed});
///   @override
///   State<AnimatedPressButton> createState() => _AnimatedPressButtonState();
/// }

/// class _AnimatedPressButtonState extends State<AnimatedPressButton> {
///   double _scale = 1.0;
///   @override
///   Widget build(BuildContext context) {
///     return GestureDetector(
///       onTapDown: (_) => setState(() => _scale = 0.96),
///       onTapUp: (_) => setState(() => _scale = 1.0),
///       onTapCancel: () => setState(() => _scale = 1.0),
///       onTap: widget.onPressed,
///       child: AnimatedScale(
///         scale: _scale,
///         duration: AppMotion.fast,
///         curve: AppMotion.standard,
///         child: widget.child,
///       ),
///     );
///   }
/// }

/// ============================================================
/// MY CAMPUS APPLICATION GUARDRAILS (compiled in lib/app_theme.dart)
/// ============================================================
///
/// Theme modes:
/// - Light, dark, and system are mandatory.
/// - Feature widgets read Theme.of(context).colorScheme; they do not hardcode
///   page surfaces or text colours.
/// - Primary remains deep indigo (#475FB1) and gold remains a restrained
///   secondary highlight. Semantic success/warning/error always include text
///   or an icon, never colour alone.
///
/// Responsive shell:
/// - Mobile < 720: top bar + navigation drawer.
/// - Tablet 720-1099: sidebar starts collapsed and remains user-expandable.
/// - Desktop >= 1100: sidebar starts expanded and can collapse to icons.
/// - Main content is centred and capped at 1440 logical pixels.
/// - Reading-focused pages may use the shared 1120 logical pixel readable cap
///   from AppLayout; feature screens do not define one-off page widths.
///
/// Component rules:
/// - Use PageHeader, SectionSurface, AppEmptyState, AppErrorState,
///   AppLoadingState, UserAvatar, and StatusBadge from shared_widgets.dart.
/// - A screen must provide loading, empty, and friendly error states before it
///   is considered connected to a repository.
/// - Hover/focus/pressed states use the centralized ThemeData. Touch targets
///   remain at least 48 logical pixels.
/// - Motion stays between 120-320ms. Avoid bounce and decorative motion.
///
/// Every new or updated page must be checked at:
/// 360x800, 412x915, 768x1024, 1366x768, and 1920x1080.
