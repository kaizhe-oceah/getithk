// Project imports:
import '../imports.dart';

class BottomNavModel {
  final int id;
  final Widget page;
  final String? title;
  final IconData? iconOn;
  final IconData? iconOff;

  const BottomNavModel({
    required this.id,
    required this.page,
    this.title,
    this.iconOn,
    this.iconOff,
  });
}
