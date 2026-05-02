import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// GarudaHub brand tokens — Merah Putih
/// Semua warna screen WAJIB pakai token di sini, bukan hardcode.
class AppColors {
  AppColors._();

  // ── Brand ──────────────────────────────────────────────────────
  static const Color primary        = Color(0xFFCC0001); // merah Garuda
  static const Color primaryDark    = Color(0xFF930000); // hover / gradient end
  static const Color primaryLight   = Color(0xFFFFEBEB); // bg tint ringan
  static const Color primaryContainer = Color(0xFFFFDAD6); // M3 primaryContainer

  // ── Neutral / Surface ──────────────────────────────────────────
  static const Color white          = Color(0xFFFFFFFF);
  static const Color bg             = Color(0xFFF4F4F4); // scaffold background
  static const Color surface        = Color(0xFFFFFFFF); // card, sheet, dialog
  static const Color surfaceVariant = Color(0xFFF9F9F9); // input fill, row alt
  static const Color border         = Color(0xFFECECEC); // card outline
  static const Color divider        = Color(0xFFE8E8E8);

  // ── Text ───────────────────────────────────────────────────────
  static const Color textPrimary    = Color(0xFF1A1A1A);
  static const Color textSecondary  = Color(0xFF6B6B6B);
  static const Color textHint       = Color(0xFFB0B0B0);
  static const Color textOnRed      = Color(0xFFFFFFFF);
  static const Color textRed        = Color(0xFFCC0001); // teks merah (harga dll)

  // ── Semantic ───────────────────────────────────────────────────
  static const Color success        = Color(0xFF2E7D32);
  static const Color successBg      = Color(0xFFE8F5E9);
  static const Color warning        = Color(0xFFE65100);
  static const Color natBadge       = Color(0xFF1565C0); // badge "NAT" biru
  static const Color natBadgeBg     = Color(0xFFE3F2FD);

  // ── Dark mode surfaces ─────────────────────────────────────────
  static const Color darkBg         = Color(0xFF121212);
  static const Color darkSurface    = Color(0xFF1E1E1E);
  static const Color darkBorder     = Color(0xFF2C2C2C);
}

/// Layout constants — gunakan ini di semua screen
class AppSpacing {
  AppSpacing._();
  static const double xs    =  4.0;
  static const double sm    =  8.0;
  static const double md    = 12.0;
  static const double base  = 16.0; // screen horizontal padding
  static const double lg    = 24.0; // section gap
  static const double xl    = 32.0;
  static const double xxl   = 48.0;
}

class AppRadius {
  AppRadius._();
  static const double sm    =  8.0;
  static const double md    = 12.0;
  static const double card  = 16.0; // SEMUA card pakai ini
  static const double lg    = 20.0;
  static const double pill  = 999.0;
}

class AppTheme {
  AppTheme._();

  // ── Light ──────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    // Mulai dari fromSeed agar M3 tokens tersedia,
    // lalu copyWith untuk memaksa warna brand yang tepat.
    final cs = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary:           AppColors.primary,
      onPrimary:         AppColors.textOnRed,
      primaryContainer:  AppColors.primaryContainer,
      onPrimaryContainer: AppColors.primaryDark,
      secondary:         AppColors.primaryDark,
      onSecondary:       AppColors.textOnRed,
      surface:           AppColors.surface,
      onSurface:         AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceVariant,
      surfaceContainerLow:     AppColors.bg,
      outline:           AppColors.border,
      outlineVariant:    AppColors.divider,
      shadow:            const Color(0x14000000),
      scrim:             const Color(0x52000000),
    );
    return _build(cs);
  }

  // ── Dark ───────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final cs = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary:          const Color(0xFFFF6B6B),
      onPrimary:        AppColors.textPrimary,
      primaryContainer: AppColors.primaryDark,
      onPrimaryContainer: AppColors.textOnRed,
      surface:          AppColors.darkSurface,
      onSurface:        const Color(0xFFE8E8E8),
      surfaceContainerHighest: AppColors.darkBg,
      outline:          AppColors.darkBorder,
    );
    return _build(cs);
  }

  // ── Builder ────────────────────────────────────────────────────
  static ThemeData _build(ColorScheme cs) {
    final bool isLight = cs.brightness == Brightness.light;

    final textTheme = GoogleFonts.plusJakartaSansTextTheme().apply(
      bodyColor:    cs.onSurface,
      displayColor: cs.onSurface,
    );

    return ThemeData(
      useMaterial3:           true,
      colorScheme:            cs,
      textTheme:              textTheme,
      scaffoldBackgroundColor: isLight ? AppColors.bg : AppColors.darkBg,

      // ── AppBar ─────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor:   cs.surface,
        surfaceTintColor:  Colors.transparent,
        elevation:         0,
        scrolledUnderElevation: 0,
        centerTitle:       false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color:       cs.onSurface,
          fontSize:    20,
          fontWeight:  FontWeight.w700,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: cs.onSurface),
        actionsIconTheme: IconThemeData(color: cs.onSurface),
      ),

      // ── Card ───────────────────────────────────────────────
      cardTheme: CardTheme(
        color:            cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation:        0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(
            color: isLight ? AppColors.border : AppColors.darkBorder,
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),

      // ── ElevatedButton ─────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          minimumSize:     const Size(double.infinity, 50),
          elevation:       0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize:    15,
            fontWeight:  FontWeight.w700,
            letterSpacing: 0.1,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical:   AppSpacing.md,
          ),
        ),
      ),

      // ── OutlinedButton ─────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.primary,
          minimumSize:     const Size(double.infinity, 50),
          side: BorderSide(color: cs.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize:   15,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical:   AppSpacing.md,
          ),
        ),
      ),

      // ── TextButton ─────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize:   14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Input / TextField ──────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled:    true,
        fillColor: isLight ? AppColors.surfaceVariant : AppColors.darkBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          borderSide: BorderSide(color: cs.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          borderSide: BorderSide(color: cs.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          borderSide: BorderSide(color: cs.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          borderSide: BorderSide(color: cs.error, width: 1.5),
        ),
        hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.38), fontSize: 14),
        labelStyle: TextStyle(color: cs.onSurfaceVariant),
        prefixIconColor: cs.onSurfaceVariant,
        suffixIconColor: cs.onSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical:   AppSpacing.md,
        ),
      ),

      // ── Chip (filter GK/DF/MF/FW) ─────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor:        isLight ? AppColors.surfaceVariant : AppColors.darkSurface,
        selectedColor:          cs.primary,
        secondarySelectedColor: cs.primary,
        disabledColor:          cs.onSurface.withOpacity(0.12),
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize:   13,
          fontWeight: FontWeight.w500,
          color:      cs.onSurface,
        ),
        secondaryLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize:   13,
          fontWeight: FontWeight.w600,
          color:      cs.onPrimary,
        ),
        side: BorderSide(color: cs.outlineVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical:   AppSpacing.xs,
        ),
        showCheckmark: true,
        checkmarkColor: cs.onPrimary,
      ),

      // ── Switch ─────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? cs.onPrimary : cs.outline),
        trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? cs.primary : cs.surfaceVariant),
        trackOutlineColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected)
            ? Colors.transparent
            : cs.outlineVariant),
      ),

      // ── Checkbox ───────────────────────────────────────────
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? cs.primary : Colors.transparent),
        checkColor: WidgetStateProperty.all(cs.onPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: BorderSide(color: cs.outline, width: 1.5),
      ),

      // ── SnackBar ───────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor:   cs.inverseSurface,
        contentTextStyle:  TextStyle(color: cs.onInverseSurface),
        actionTextColor:   cs.inversePrimary,
        behavior:          SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),

      // ── Dialog ─────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor:  cs.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color:      cs.onSurface,
          fontSize:   18,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: GoogleFonts.plusJakartaSans(
          color:  cs.onSurfaceVariant,
          fontSize: 14,
          height: 1.5,
        ),
      ),

      // ── BottomSheet ────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor:  cs.surface,
        surfaceTintColor: Colors.transparent,
        dragHandleColor:  cs.outlineVariant,
        showDragHandle:   true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
        ),
      ),

      // ── NavigationBar (floating bottom nav) ───────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor:  cs.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor:      cs.shadow,
        elevation:        8,
        indicatorColor:   cs.primaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((s) {
          final selected = s.contains(WidgetState.selected);
          return GoogleFonts.plusJakartaSans(
            color:      selected ? cs.primary : cs.onSurfaceVariant,
            fontSize:   11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((s) {
          final selected = s.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? cs.primary : cs.onSurfaceVariant,
            size:  24,
          );
        }),
      ),

      // ── Divider ────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color:     cs.outlineVariant,
        thickness: 0.5,
        space:     1,
      ),

      // ── ListTile ───────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical:   AppSpacing.xs,
        ),
        minLeadingWidth: 24,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color:      cs.onSurface,
          fontSize:   14,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: GoogleFonts.plusJakartaSans(
          color:    cs.onSurfaceVariant,
          fontSize: 12,
        ),
      ),

      // ── PopupMenu ──────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color:            cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation:        4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),

      // ── ProgressIndicator ──────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color:            cs.primary,
        linearTrackColor: cs.primaryContainer,
        circularTrackColor: cs.primaryContainer,
      ),

      // ── FloatingActionButton ───────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation:       4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),

      // ── TabBar ─────────────────────────────────────────────
      tabBarTheme: TabBarTheme(
        labelColor:        cs.primary,
        unselectedLabelColor: cs.onSurfaceVariant,
        indicatorColor:    cs.primary,
        indicatorSize:     TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize:   14,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize:   14,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: cs.outlineVariant,
      ),
    );
  }
}
