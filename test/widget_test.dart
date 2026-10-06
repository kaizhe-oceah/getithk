// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:getithk/routes/route_name.dart';

void main() {
  test('route names are registered', () {
    expect(RouteName.containsRoute(RouteName.splashPage), isTrue);
    expect(RouteName.containsRoute(RouteName.mainPage), isTrue);
    expect(RouteName.containsRoute(RouteName.loginPage), isTrue);
    expect(RouteName.containsRoute('/not-a-route'), isFalse);
  });
}
