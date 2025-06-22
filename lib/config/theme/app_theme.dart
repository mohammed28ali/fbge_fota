import 'package:flutter/material.dart';
import 'package:fota_uploader/core/utils/app_colors.dart';

ThemeData appTheme() {
  return ThemeData(
    primaryColor: AppColors.primaryColor,
    hintColor: AppColors.hintColor,
    brightness: Brightness.light,
    splashColor: Colors.transparent,
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: AppColors.primaryColor,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryColor,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.primaryColor,
    ),
    unselectedWidgetColor: AppColors.primaryColor,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      color: Colors.transparent,
      elevation: 0.0,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        color: AppColors.primaryColor,
        height: 1.3,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    tabBarTheme: TabBarThemeData(indicatorColor: AppColors.primaryColor),
  );
}
