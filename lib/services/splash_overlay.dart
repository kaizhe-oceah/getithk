// Dart imports:
import 'dart:math' as math;

// Project imports:
import 'package:getithk/imports.dart';

/// Covers the route change out of the splash page with the splash background,
/// then fades it out to show the new page.
class SplashOverlay {
  static OverlayEntry? _entry;

  static Future<void> show({Duration? duration}) async {
    if (_entry != null) return;

    final overlay = NavigationService.overlay;
    if (overlay == null) return;

    _entry = OverlayEntry(builder: (_) => _SplashExit(duration: duration));

    overlay.insert(_entry!);
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
  }
}

/// The splash screen.
///
/// Intro, driven by [progress] (0 → 1):
/// 1. a primary-colour glow builds up behind the centre;
/// 2. the logo appears big in the centre and spins one fast full turn while
///    shrinking to its normal size;
/// 3. it then slides left as the app name slides in from the right, so the
///    pair ends up centred.
///
/// Outro, driven by [outro] (0 → 1): the logo fades out, then the app name.
///
/// Shared by the splash page and [SplashOverlay] so the hand-off between
/// them is seamless.
class SplashView extends StatelessWidget {
  final double progress;
  final double outro;

  const SplashView({this.progress = 1, this.outro = 0, super.key});

  static const Duration introDuration = Duration(milliseconds: 1600);
  static const Duration outroDuration = Duration(milliseconds: 700);

  static double get _logoSize => 72.fw;
  static double get _nameHeight => _logoSize * 0.47;
  static double get _nameWidth => _nameHeight * 3024 / 512;
  static double get _gap => _logoSize * 0.14;
  static double get _width => _logoSize + _gap + _nameWidth;

  /// How big the logo starts before shrinking into place.
  static const double _startScale = 2.6;

  // intro
  static const Curve _glowCurve = Interval(0.0, 0.5, curve: Curves.easeOut);
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

  // outro
  static const Curve _logoOutCurve = Interval(0.0, 0.55, curve: Curves.easeOut);
  static const Curve _nameOutCurve = Interval(0.3, 0.85, curve: Curves.easeOut);

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
        _glow(_glowCurve.transform(progress)),
        Center(child: _brand()),
      ],
    );
  }

  /// Broad primary-colour radial glow behind the centre.
  Widget _glow(double value) {
    return Opacity(
      opacity: value,
      child: Transform.scale(
        scale: 0.7 + 0.3 * value,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              radius: 0.9,
              colors: [
                AppColors.primaryColor.wOpacity(0.45),
                AppColors.primaryColor.wOpacity(0.18),
                AppColors.primaryColor.wOpacity(0.05),
                AppColors.primaryColor.wOpacity(0),
              ],
              stops: const [0, 0.3, 0.6, 1],
            ),
          ),
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

    final double logoOpacity =
        _fadeInCurve.transform(progress) * (1 - _logoOutCurve.transform(outro));
    final double nameOpacity = nameIn * (1 - _nameOutCurve.transform(outro));

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
                opacity: nameOpacity.clamp(0.0, 1.0),
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

class _SplashExit extends StatefulWidget {
  final Duration? duration;

  const _SplashExit({required this.duration});

  @override
  State<_SplashExit> createState() => _SplashExitState();
}

class _SplashExitState extends State<_SplashExit>
    with SingleTickerProviderStateMixin {
  // The first part holds the splash background while the route underneath
  // finishes its own transition.
  static const Curve _fadeCurve = Interval(0.4, 1.0, curve: Curves.easeOut);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration ?? const Duration(milliseconds: 750),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward().then((_) => SplashOverlay.hide());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: 1 - _fadeCurve.transform(_controller.value),
        child: child,
      ),
      child: const SplashView(outro: 1),
    );
  }
}
