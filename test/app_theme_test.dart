import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mithaq_al_mumin/app/app_theme.dart';

void main() {
  group('Mithaq visual system', () {
    test('uses the intended dark emerald and gold palette', () {
      final theme = AppTheme.dark;

      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, AppPalette.deepGreen);
      expect(theme.colorScheme.primary, AppPalette.accentGold);
      expect(AppPalette.panelGreen, const Color(0xFF123A2D));
    });

    test('provides shared styles for navigation and Arabic-friendly inputs', () {
      final theme = AppTheme.dark;

      expect(theme.navigationBarTheme.backgroundColor, const Color(0xFF051811));
      expect(theme.inputDecorationTheme.filled, isTrue);
      expect(theme.appBarTheme.centerTitle, isTrue);
    });
  });
}
