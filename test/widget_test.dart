import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:popsign/i_heart_you_app.dart';

void main() {
  testWidgets('App boots to the splash screen without crashing', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const IHeartYouApp());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Let the splash screen's 2-second navigation timer fire so it doesn't
    // leak past the end of the test.
    await tester.pump(const Duration(seconds: 3));
  });
}
