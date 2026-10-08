// Project imports:
import '../../imports.dart';

class CircularProgressIndicatorWidget extends StatefulWidget {
  final double size;

  final String? image;

  final String? text;

  final bool showText;

  const CircularProgressIndicatorWidget({
    this.size = 56,
    this.image,
    this.text,
    this.showText = true,
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

    final Widget image = RepaintBoundary(
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
            cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
            filterQuality: FilterQuality.medium,
          ),
        ),
      ),
    );
    if (!widget.showText) return image;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        image,
        8.heightSpace,
        AppText(
          widget.text ?? context.tr(AppStrings.loading),
          fontSize: kFont12,
          color: AppColors.greyColor,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
