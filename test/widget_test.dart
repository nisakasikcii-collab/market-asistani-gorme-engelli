import "package:eyeshopper_ai/app.dart";
import "package:flutter_test/flutter_test.dart";
import "package:shared_preferences/shared_preferences.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("EsApp açılır", (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const EsApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text("Eyeshopper AI"), findsOneWidget);
  });
}
