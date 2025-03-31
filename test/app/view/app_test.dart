import 'package:flutter_test/flutter_test.dart';
import 'package:holz_logistik/app/app.dart';
import 'package:holz_logistik/counter/counter.dart';

void main() {
  group('App', () {
    testWidgets('renders CounterPage', (tester) async {
      await tester.pumpWidget(const App());
      expect(find.byType(CounterPage), findsOneWidget);
    });
  });
}
