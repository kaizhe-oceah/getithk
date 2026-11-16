// Project imports:
import '../imports.dart';

/// GetItHK logo: the round mark next to the "GET iT" name.
///
/// [height] is the size of the mark; the name scales with it. The name is
/// white on a dark background: in dark mode, or wherever [onDark] says.
class AppLogo extends StatelessWidget {
  final double height;
  final bool? onDark;

  const AppLogo({this.height = 36, this.onDark, super.key});

  /// Height of the name relative to the mark.
  static const double nameHeightRatio = 0.47;

  /// Width / height of the name images.
  static const double nameAspectRatio = 3024 / 512;

  /// Space between the mark and the name, relative to the mark.
  static const double gapRatio = 0.25;

  @override
  Widget build(BuildContext context) {
    final double nameHeight = height * nameHeightRatio;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          AppAssets.appLogo,
          width: height,
          height: height,
          fit: BoxFit.contain,
        ),
        SizedBox(width: height * gapRatio),
        Image.asset(
          (onDark ?? AppColors.isDark)
              ? AppAssets.appName
              : AppAssets.appNameDark,
          width: nameHeight * nameAspectRatio,
          height: nameHeight,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}
