import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aplication_tesis/core/services/onboarding_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('hasSeen() returns false by default (key absent)', () async {
    final svc = OnboardingService();
    expect(await svc.hasSeen(), false);
  });

  test('markSeen() sets hasSeen to true', () async {
    final svc = OnboardingService();
    await svc.markSeen();
    expect(await svc.hasSeen(), true);
  });

  test('reset() clears the flag so hasSeen returns false', () async {
    final svc = OnboardingService();
    await svc.markSeen();
    expect(await svc.hasSeen(), true);
    await svc.reset();
    expect(await svc.hasSeen(), false);
  });
}
