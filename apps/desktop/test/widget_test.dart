import 'package:flutter_test/flutter_test.dart';

import 'package:desktop/main.dart';
import 'package:desktop/services/download_service.dart';
import 'package:desktop/services/settings_service.dart';

void main() {
  testWidgets('App launches and shows the Downloads view', (WidgetTester tester) async {
    final settings = SettingsService();
    final downloads = DownloadService(settings);

    await tester.pumpWidget(NimbusApp(settings: settings, downloads: downloads));

    // The sidebar brand and the default Downloads page should be present.
    expect(find.text('Nimbus'), findsWidgets);
    expect(find.text('Downloads'), findsWidgets);
  });
}
