
import 'package:flutter_test/flutter_test.dart';
import 'package:pt3/main.dart';

void main() {
  testWidgets('Splash screen to Login screen flow test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('TASK AUTHENTICATOR'), findsOneWidget);
    expect(find.text('Firebase & Local JSON Sync'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Login to sync your bookmarks securely'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
