import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pe/widgets/claim_form.dart';

void main() {
  testWidgets('claim form validates required fields', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ClaimForm(userId: 'staff-1', onSubmit: (_) async {}),
        ),
      ),
    );

    await tester.tap(find.text('Add claim'));
    await tester.pump();

    expect(find.text('Enter a claim title'), findsOneWidget);
    expect(find.text('Enter a valid amount'), findsOneWidget);
  });
}
