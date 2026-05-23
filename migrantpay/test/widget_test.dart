import 'package:flutter_test/flutter_test.dart';
import 'package:migrantpay/main.dart';
import 'package:migrantpay/providers/app_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final appProvider = AppProvider();
    // Build our app and trigger a frame.
    await tester.pumpWidget(MigrantPayApp(appProvider: appProvider));

    // Verify splash screen or app title is present.
    expect(find.byType(MigrantPayApp), findsOneWidget);
  });
}
