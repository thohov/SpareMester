import 'package:flutter_test/flutter_test.dart';
import 'package:pengespareapp/main.dart';
import 'package:pengespareapp/src/features/settings/data/app_settings.dart';

void main() {
  test('AppSettings.copyWith can clear nullable fields explicitly', () {
    final initial = AppSettings(
      monthlyBudget: 5000,
      lastDecisionDate: DateTime(2026, 1, 1),
    );

    final cleared = initial.copyWith(
      monthlyBudget: null,
      lastDecisionDate: null,
    );

    expect(cleared.monthlyBudget, isNull);
    expect(cleared.lastDecisionDate, isNull);
  });

  test('MyApp type is available', () {
    // Lightweight sanity test that verifies the app entry widget exists.
    expect(const MyApp(), isA<MyApp>());
  });
}
