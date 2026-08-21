import 'package:flutter_test/flutter_test.dart';

import 'package:free_parking_finland/main.dart';
import 'package:free_parking_finland/services/ads_service.dart';
import 'package:free_parking_finland/services/auth_service.dart';

void main() {
  testWidgets('App launches and shows the app bar title', (tester) async {
    await tester.pumpWidget(
      FreeParkingApp(authService: AuthService(), adsService: AdsService()),
    );
    await tester.pump();

    expect(find.text('Free Parking Finland'), findsOneWidget);
  });
}
