// Project imports:
import '../imports.dart';

class BottomNavModel {
  final int id;
  final Widget page;
  final String? title;
  final IconData? iconOn;
  final IconData? iconOff;

  /// The page's background, behind the floating nav bar; picks light or
  /// dark glass for the bar on this tab.
  final Color backgroundColor;

  const BottomNavModel({
    required this.id,
    required this.page,
    required this.backgroundColor,
    this.title,
    this.iconOn,
    this.iconOff,
  });
}
