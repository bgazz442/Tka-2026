import 'package:flutter_test/flutter_test.dart';

import 'package:futureee/app/app.dart';

void main() {
  testWidgets('app loads and shows splash screen', (tester) async {
    await tester.pumpWidget(const TkaStudyApp());

    expect(find.text('TKA Study'), findsWidgets);
  });
}
