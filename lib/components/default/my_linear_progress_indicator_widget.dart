// Project imports:
import '../../imports.dart';

const double _kMyLinearProgressIndicatorHeight = 6.0;

// ignore: must_be_immutable
class MyLinearProgressIndicatorWidget extends LinearProgressIndicator
    implements PreferredSizeWidget {
  MyLinearProgressIndicatorWidget({
    super.key,
    super.value,
    super.backgroundColor,
    Animation<Color>? super.valueColor,
  }) {
    preferredSize =
        const Size(double.infinity, _kMyLinearProgressIndicatorHeight);
  }

  @override
  late Size preferredSize;
}
