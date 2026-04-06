import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unibook/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('UniBook app boots to splash screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const UniBookApp());
    await tester.pump();

    expect(find.byType(UniBookApp), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });
}
