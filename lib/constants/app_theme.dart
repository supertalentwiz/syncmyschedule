import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_sizes.dart';

class AppTheme {
  static final ThemeData theme = ThemeData(
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.fromSwatch().copyWith(secondary: AppColors.accent),
    scaffoldBackgroundColor: AppColors.background,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: AppColors.accent,
        fontSize: AppSizes.titleFontSize,
        fontWeight: FontWeight.bold,
      ),
      bodyMedium: TextStyle(color: AppColors.primary),
      bodySmall: TextStyle(color: AppColors.accent),
      titleLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.background,
      ),
      titleMedium: TextStyle(fontSize: 18, color: AppColors.background),
      headlineSmall: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: TextStyle(color: AppColors.accent),
      hintStyle: TextStyle(color: AppColors.textFieldHint),
      filled: true,
      fillColor: AppColors.textFieldFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        borderSide: BorderSide(color: AppColors.accent, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        padding: EdgeInsets.symmetric(vertical: AppSizes.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
        textStyle: TextStyle(fontSize: AppSizes.buttonFontSize),
      ),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.dialogBorderRadius),
      ),
    ),
    cardTheme: CardThemeData(
      margin: EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      color: AppColors.textFieldFill,
      elevation: 6,
    ),
  );

  static BoxDecoration gradientButtonDecoration = BoxDecoration(
    gradient: const LinearGradient(
      colors: [AppColors.accent, Color(0xFFFFC107)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
    boxShadow: const [
      BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
    ],
  );
}
