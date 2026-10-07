// Dart imports:
import 'dart:math' as math;

// Project imports:
import '../imports.dart';

/// The splash screen.
///
/// A soft primary-colour glow sits behind the centre the whole time.
///
/// Intro, driven by [progress] (0 → 1):
/// 1. the logo appears big in the centre and spins one fast full turn while
///    shrinking to its normal size;
/// 2. it then slides left as the app name slides in from the right, so the
///    pair ends up centred.
class SplashView extends StatelessWidget {
  final double progress;

  const SplashView({this.progress = 1, super.key});

  static const Duration introDuration = Duration(milliseconds: 1600);

  static double get _logoSize => 72.fw;
  static double get _nameHeight => _logoSize * AppLogo.nameHeightRatio;
  static double get _nameWidth => _nameHeight * AppLogo.nameAspectRatio;
  static double get _gap => _logoSize * 0.14; // tighter than AppLogo
  static double get _width => _logoSize + _gap + _nameWidth;

  /// How big the logo starts before shrinking into place.
  static const double _startScale = 2.6;

  // intro
  static const Curve _fadeInCurve = Interval(0.0, 0.1, curve: Curves.easeOut);
  static const Curve _spinCurve = Interval(
    0.0,
    0.32,
    curve: Curves.easeOutCubic,
  );
  static const Curve _shrinkCurve = Interval(
    0.0,
    0.38,
    curve: Curves.easeOutCubic,
  );
  static const Curve _shiftCurve = Interval(
    0.4,
    0.66,
    curve: Curves.easeInOutCubic,
  );
  static const Curve _nameInCurve = Interval(
    0.52,
    0.85,
    curve: Curves.easeOutCubic,
  );

  /// Load both images up front so the first animated frame isn't blank.
  static Future<void> precache(BuildContext context) => Future.wait([
    precacheImage(AssetImage(AppAssets.appLogo), context),
    precacheImage(AssetImage(AppAssets.appName), context),
  ]);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AppColors.darkBackgroundColor),
        _glow(),
        Center(child: _brand()),
      ],
    );
  }

  /// Soft primary-colour radial glow behind the centre.
  Widget _glow() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          radius: 1.0,
          colors: [
            AppColors.primaryColor.wOpacity(0.22),
            AppColors.primaryColor.wOpacity(0.1),
            AppColors.primaryColor.wOpacity(0.03),
            AppColors.primaryColor.wOpacity(0),
          ],
          stops: const [0, 0.35, 0.7, 1],
        ),
      ),
    );
  }

  Widget _brand() {
    final double spin = _spinCurve.transform(progress);
    final double scale =
        _startScale - (_startScale - 1) * _shrinkCurve.transform(progress);
    final double shift = _shiftCurve.transform(progress);
    final double nameIn = _nameInCurve.transform(progress);

    final double logoOpacity = _fadeInCurve.transform(progress);

    return SizedBox(
      width: _width,
      height: _logoSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // App name: slides in from the right while fading in
          Positioned(
            left: _logoSize + _gap,
            top: (_logoSize - _nameHeight) / 2,
            child: Transform.translate(
              offset: Offset((1 - nameIn) * 48.fw, 0),
              child: Opacity(
                opacity: nameIn.clamp(0.0, 1.0),
                child: Image.asset(
                  AppAssets.appName,
                  width: _nameWidth,
                  height: _nameHeight,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Logo: starts big in the centre, spins in, then moves to the left
          Positioned(
            left: 0,
            top: 0,
            child: Transform.translate(
              offset: Offset((1 - shift) * (_width - _logoSize) / 2, 0),
              child: Opacity(
                opacity: logoOpacity.clamp(0.0, 1.0),
                child: Transform.rotate(
                  angle: (spin - 1) * 2 * math.pi,
                  child: Transform.scale(
                    scale: scale,
                    child: Image.asset(
                      AppAssets.appLogo,
                      width: _logoSize,
                      height: _logoSize,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
