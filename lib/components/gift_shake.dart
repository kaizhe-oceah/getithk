// Dart imports:
import 'dart:math' as math;

// Project imports:
import '../imports.dart';

/// [child], every [period] rocked side to side on its base a few times, like
/// a gift about to open, swelling a touch as it goes, then still till the
/// next. Still throughout when the system asks for less motion.
class GiftShake extends StatefulWidget {
  final Widget child;
  final Duration period;

  const GiftShake({
    required this.child,
    this.period = const Duration(milliseconds: 2400),
    super.key,
  });

  @override
  State<GiftShake> createState() => _GiftShakeState();
}

class _GiftShakeState extends State<GiftShake>
    with SingleTickerProviderStateMixin {
  /// The share of each period spent shaking; the rest, still.
  static const double _shakeShare = 0.4;
  static const int _swings = 4;

  /// About 8°, at the first swing; each after it smaller.
  static const double _maxAngle = 0.14;
  static const double _maxSwell = 0.06;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.period,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        // 0 → 1 through the shake, then held at 1 while still
        final double t = (_controller.value / _shakeShare).clamp(0.0, 1.0);
        final double angle =
            math.sin(t * _swings * 2 * math.pi) * _maxAngle * (1 - t);
        final double swell = math.sin(t * math.pi) * _maxSwell;

        return Transform.rotate(
          angle: angle,
          alignment: Alignment.bottomCenter,
          child: Transform.scale(scale: 1 + swell, child: child),
        );
      },
    );
  }
}
