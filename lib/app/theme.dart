// lib/app/theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      primaryColor: Colors.blueAccent,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        color: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        buttonColor: Colors.blueAccent,
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.blueAccent,
          textStyle: const TextStyle(fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      // ✅ CardTheme 대신 CardThemeData를 사용합니다.
      cardTheme: CardThemeData( // CardThemeData로 수정
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      ),
      // 텍스트 스타일 정의
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.bold, color: Colors.black87),
        displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.black87),
        displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black87),
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
        bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.black87),
        bodySmall: TextStyle(fontSize: 12, color: Colors.black54),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87),
        labelSmall: TextStyle(fontSize: 11, color: Colors.black54),
      ),
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(secondary: Colors.amber),
    );
  }
}
