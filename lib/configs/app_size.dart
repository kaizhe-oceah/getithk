// Project imports:
import '../imports.dart';

class AppSize {
  // for mobile web
  static double mobileWebWidth = kIsWeb ? 470.w : 1.sw;
  static double getSize(num size) {
    return width * (size / mobileWebWidth);
  }

  // get app width
  static double get width => kIsWeb
      ? (1.sw < mobileWebWidth
          ? (mobileWebWidth - (mobileWebWidth - 1.sw))
          : mobileWebWidth)
      : 1.sw;

  // get app heightZ
  static double get height => 1.sh;
}
