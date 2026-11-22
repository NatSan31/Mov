import 'package:flutter_test/flutter_test.dart';
import 'package:fitpulse_app/main.dart';

void main() {
  testWidgets('FitPulse smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FitPulseApp());
  });
}
