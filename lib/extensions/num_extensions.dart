// Project imports:
import '../imports.dart';

extension NumExtensions on num {
  /// App Size usage
  double get fw => kIsWeb ? AppSize.getSize(this).w : (this).w;
  double get fh => kIsWeb ? AppSize.getSize(this).w : (this).h;
  double get fr => kIsWeb ? AppSize.getSize(this).w : (this).r;

  /// height spacer
  SizedBox get heightSpace =>
      SizedBox(height: kIsWeb ? AppSize.getSize(this).w : (this).h);

  /// width spacer
  SizedBox get widthSpace =>
      SizedBox(width: kIsWeb ? AppSize.getSize(this).w : (this).w);

  /// horizontal divider
  Widget get dividerHorizontal => Container(
        height: kIsWeb ? AppSize.getSize(this).w : (this).h,
        color: const Color.fromARGB(255, 238, 237, 237),
      );

  /// vertical divider
  Widget get dividerVertical => Container(
        width: kIsWeb ? AppSize.getSize(this).w : (this).w,
        color: const Color.fromRGBO(222, 222, 222, 1),
      );

  /// Checks if num a LOWER than num b.
  bool isLowerThan(num b) => this < b;

  /// Checks if num a GREATER than num b.
  bool isGreaterThan(num b) => this > b;

  /// Checks if num a EQUAL than num b.
  bool isEqual(num b) => this == b;

  /// Utility to delay some callback (or code execution).
  Future delay([FutureOr Function()? callback]) async => Future.delayed(
        Duration(milliseconds: (this * 1000).round()),
        callback,
      );

  Duration get milliseconds => Duration(microseconds: (this * 1000).round());

  Duration get seconds => Duration(milliseconds: (this * 1000).round());

  Duration get minutes =>
      Duration(seconds: (this * Duration.secondsPerMinute).round());

  Duration get hours =>
      Duration(minutes: (this * Duration.minutesPerHour).round());

  Duration get days => Duration(hours: (this * Duration.hoursPerDay).round());
}
