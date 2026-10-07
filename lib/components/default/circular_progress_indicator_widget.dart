// Project imports:
import '../../imports.dart';

/// The app's loading indicator: an image spinning, one full turn every
/// [_turnDuration]. Used by the Loader overlay, pull-to-refresh and
/// CustomFutureBuilder.
class CircularProgressIndicatorWidget extends StatefulWidget {
  final double size;

  /// The spinning image; the app icon unless set.
  final String? image;

  const CircularProgressIndicatorWidget({
    this.size = 56,
    this.image,
    super.key,
  });

  @override
  State<CircularProgressIndicatorWidget> createState() =>
      _CircularProgressIndicatorWidgetState();
}

class _CircularProgressIndicatorWidgetState
    extends State<CircularProgressIndicatorWidget>
    with SingleTickerProviderStateMixin {
  static const Duration _turnDuration = Duration(milliseconds: 700);

  // linear, so the spin is even and never slows between turns
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _turnDuration,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.size.fh;

    return RepaintBoundary(
      child: SizedBox(
        width: size,
        height: size,
        child: RotationTransition(
          turns: _controller,
          child: Image.asset(
            widget.image ?? AppAssets.appIcon,
            width: size,
            height: size,
            fit: BoxFit.contain,
            // the asset is 512px; decode it at the size it's shown, and filter
            // it smoothly so the edges don't shimmer while it turns
            cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
            filterQuality: FilterQuality.medium,
          ),
        ),
      ),
    );
  }
}
