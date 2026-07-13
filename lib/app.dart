import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'ui/shell/app_shell.dart';

/// Light purple brand palette for Image Finder.
class AppColors {
  static const Color seed = Color(0xFF9A7BCC);
  static const Color primary = Color(0xFF8B6BC0);
  static const Color primarySoft = Color(0xFFE8DEF8);
  static const Color surface = Color(0xFFF7F4FB);
}

class ImageFinderApp extends StatelessWidget {
  const ImageFinderApp({super.key});


//jkjweh wek 

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: Brightness.light,
      primary: AppColors.primary,
      surface: AppColors.surface,
    );

    final textTheme = GoogleFonts.outfitTextTheme(ThemeData.light().textTheme);

    return ProviderScope(
      child: MaterialApp(
        title: 'Image Finder',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: colorScheme,
          textTheme: textTheme,
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.surface,
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.surface,
            foregroundColor: colorScheme.onSurface,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: false,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: AppColors.primary,
          ),
        ),
        home: const AppShell(),
      ),
    );
  }
}
