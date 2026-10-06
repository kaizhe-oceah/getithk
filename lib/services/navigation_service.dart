// Project imports:
import '../imports.dart';

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static BuildContext get context => navigatorKey.currentContext!;
  static NavigatorState get state => navigatorKey.currentState!;

  /// The root navigator's own overlay.
  ///
  /// Do not use `Overlay.of(NavigationService.context)` — that context IS the
  /// root [Navigator], and `Overlay.of` only walks up the tree, while the
  /// navigator's overlay is a descendant of it.
  static OverlayState? get overlay => navigatorKey.currentState?.overlay;
}
