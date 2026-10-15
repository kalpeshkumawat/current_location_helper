
import 'package:flutter_test/flutter_test.dart';
import 'package:current_location_helper_example/main.dart';

void main() {
  testWidgets('Current location app launches', (WidgetTester tester) async {
    await tester.pumpWidget(const CurrentLocationApp());

    expect(find.byType(CurrentLocationApp), findsOneWidget);
    expect(find.text('GetUserLocation'), findsOneWidget);
    expect(find.text('One-time location'), findsOneWidget);
    expect(find.text('Continuous (every 5s)'), findsOneWidget);
    expect(find.text('Stop tracking'), findsOneWidget);
  });
}
