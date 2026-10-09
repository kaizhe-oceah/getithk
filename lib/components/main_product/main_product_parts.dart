// Project imports:
import '../../imports.dart';
import '../../models/main_product_model.dart';

String formatMainProductAmount(double value) =>
    NumberFormat('#,##0.##').format(value);

class MainProductImage extends StatelessWidget {
  final String? image;

  const MainProductImage({required this.image, super.key});

  static const double bannerAspectRatio = 1280 / 714;

  @override
  Widget build(BuildContext context) {
    return AppImage(name: image, width: double.infinity, fit: BoxFit.cover);
  }
}

class MainProductTags extends StatelessWidget {
  final List<MainProductTagModel> tags;

  const MainProductTags({required this.tags, super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6.r,
      runSpacing: 6.r,
      children: [
        for (final MainProductTagModel tag in tags)
          if ((tag.name ?? '').isNotEmpty) _tag(tag),
      ],
    );
  }

  Widget _tag(MainProductTagModel tag) {
    final Color color = tag.colorValue ?? AppColors.greyColor;
    final bool light = color.computeLuminance() > 0.55;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2).r,
      decoration: BoxDecoration(
        color: color.wOpacity(light ? 0.25 : 0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(100),
      ),
      child: AppText(
        tag.name!,
        fontSize: kFont12,
        fontWeight: FontWeight.w500,
        color: _readableOnWhite(color),
      ),
    );
  }

  static Color _readableOnWhite(Color color) {
    HSLColor hsl = HSLColor.fromColor(color);
    while (hsl.toColor().computeLuminance() > 0.3 && hsl.lightness > 0) {
      hsl = hsl.withLightness((hsl.lightness - 0.02).clamp(0.0, 1.0));
    }
    return hsl.toColor();
  }
}

class MainProductPriceAndStock extends StatelessWidget {
  final MainProductModel product;

  const MainProductPriceAndStock({required this.product, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        MainProductPrice(product: product),
        16.widthSpace,
        Expanded(child: MainProductStock(product: product)),
      ],
    );
  }
}

class MainProductPrice extends StatelessWidget {
  final MainProductModel product;

  const MainProductPrice({required this.product, super.key});

  @override
  Widget build(BuildContext context) {
    final double coinSize = 18.r;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppImage(
          name: AppAssets.coins,
          width: coinSize,
          height: coinSize,
          fit: BoxFit.contain,
          cacheWidth: (coinSize * MediaQuery.devicePixelRatioOf(context))
              .round(),
        ),
        4.widthSpace,
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: formatMainProductAmount(product.drawAmount),
                style: TextStyle(
                  fontSize: kFont16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.loginTextColor,
                ),
              ),
              TextSpan(
                text: ' ${context.tr(AppStrings.perDraw)}',
                style: TextStyle(
                  fontSize: kFont12.sp,
                  color: AppColors.textLightColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MainProductStock extends StatelessWidget {
  final MainProductModel product;

  const MainProductStock({required this.product, super.key});

  static const Color _amber = Color(0xFFF59E0B);
  static const Color _green = Color(0xFF22C55E);

  @override
  Widget build(BuildContext context) {
    final double left = product.totalDraws > 0
        ? (product.remainingDraws / product.totalDraws).clamp(0.0, 1.0)
        : 0;
    final Color barColor = left < 0.2
        ? context.color.primary
        : left < 0.5
        ? _amber
        : _green;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: kFont11.sp,
              color: AppColors.textLightColor,
            ),
            children: [
              TextSpan(text: '${context.tr(AppStrings.remainingStock)} '),
              TextSpan(
                text: '${product.remainingDraws}/${product.totalDraws}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.loginTextColor,
                ),
              ),
            ],
          ),
        ),
        4.heightSpace,
        Container(
          height: 8.r,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: barColor.wOpacity(0.15),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: left,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.lerp(barColor, AppColors.whiteColor, 0.35)!,
                      barColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MainProductTopupUnlock extends StatefulWidget {
  final MainProductModel product;

  const MainProductTopupUnlock({required this.product, super.key});

  @override
  State<MainProductTopupUnlock> createState() => _MainProductTopupUnlockState();
}

class _MainProductTopupUnlockState extends State<MainProductTopupUnlock>
    with SingleTickerProviderStateMixin {
  static const Color _background = Color(0xFFF6F4FF);
  static const double _borderWidth = 1.5;
  static const Duration _flowDuration = Duration(seconds: 6);
  static const List<Color> _amountColors = [
    Color(0xFF2F6BFF),
    Color(0xFFA334D6),
    Color(0xFFE6248C),
    Color(0xFF2F6BFF),
  ];

  late final AnimationController _flow = AnimationController(
    vsync: this,
    duration: _flowDuration,
  )..repeat();

  @override
  void dispose() {
    _flow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MainProductModel product = widget.product;
    final int? left = product.remainingUnlockedDraws;

    final double radius = 10.r;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _flow,
        builder: (context, child) => DecoratedBox(
          decoration: BoxDecoration(
            gradient: _flowingGradient(_amountColors, _flow.value),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: child,
        ),
        child: Padding(
          padding: const EdgeInsets.all(_borderWidth),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: _background,
              borderRadius: BorderRadius.circular(radius - _borderWidth),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ribbon(context),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12).r,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              context.tr(AppStrings.topupMore),
                              fontSize: kFont14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.loginTextColor,
                            ),
                            _amount(product.topupToNextUnlock ?? 0),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _info(
                            context.tr(AppStrings.drawsAvailableNow),
                            context.tr(
                              AppStrings.drawTimes,
                              args: ['${product.availableDraws ?? 0}'],
                            ),
                            flowing: true,
                          ),
                          6.heightSpace,
                          _info(
                            context.tr(AppStrings.chanceToGet),
                            left == null
                                ? context.tr(AppStrings.unlimited)
                                : context.tr(
                                    AppStrings.drawTimes,
                                    args: ['$left'],
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _ribbon(BuildContext context) {
    return RepaintBoundary(
      child: ClipPath(
        clipper: const _SwallowtailClipper(),
        child: AnimatedBuilder(
          animation: _flow,
          builder: (context, child) => DecoratedBox(
            decoration: BoxDecoration(
              gradient: _flowingGradient(_amountColors, _flow.value),
            ),
            child: child,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 4, 20, 4).r,
            child: AppText(
              context.tr(
                AppStrings.topupPerDraw,
                args: [
                  formatMainProductAmount(widget.product.topupPerDraw ?? 0),
                ],
              ),
              fontSize: kFont12,
              fontWeight: FontWeight.w700,
              color: AppColors.whiteColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _amount(double value) {
    return _FlowingGradient(
      flow: _flow,
      colors: _amountColors,
      child: Text.rich(
        TextSpan(
          style: const TextStyle(fontWeight: FontWeight.w700),
          children: [
            TextSpan(
              text: formatMainProductAmount(value),
              style: const TextStyle(fontSize: kFont26),
            ),
            const TextSpan(
              text: ' pt',
              style: TextStyle(fontSize: kFont14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String value, {bool flowing = false}) {
    final TextStyle style = TextStyle(
      fontSize: kFont13.sp,
      color: AppColors.loginTextColor,
    );
    final Widget valueText = Text(
      value,
      style: style.copyWith(fontWeight: FontWeight.w700),
    );

    // a Row rather than one Text.rich, so the value alone can take the
    // flowing gradient; baseline-aligned so it still reads as one line
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(label, style: style),
        if (flowing)
          _FlowingGradient(flow: _flow, colors: _amountColors, child: valueText)
        else
          valueText,
      ],
    );
  }
}

/// A ribbon whose right end has a V notch cut into it.
class _SwallowtailClipper extends CustomClipper<Path> {
  const _SwallowtailClipper();

  @override
  Path getClip(Size size) {
    final double notch = size.height * 0.3;

    return Path()
      ..lineTo(size.width, 0)
      ..lineTo(size.width - notch, size.height / 2)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(_SwallowtailClipper oldClipper) => false;
}

/// [colors] spread over twice the painted width, slid left by [progress] of
/// that span: about half the colors show at once, so they drift in from the
/// right rather than flash, and 0 and 1 look the same. [colors] should start
/// and end on the same color, or the loop shows a seam.
LinearGradient _flowingGradient(List<Color> colors, double progress) {
  return LinearGradient(
    end: const Alignment(3, 0),
    colors: colors,
    tileMode: TileMode.repeated,
    transform: _SlideGradient(progress),
  );
}

/// Paints [child] in [_flowingGradient], moving as [flow] runs.
class _FlowingGradient extends StatelessWidget {
  final Animation<double> flow;
  final List<Color> colors;
  final Widget child;

  const _FlowingGradient({
    required this.flow,
    required this.colors,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: flow,
        child: child,
        builder: (context, child) => ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: _flowingGradient(colors, flow.value).createShader,
          child: child,
        ),
      ),
    );
  }
}

/// Shifts a gradient left by [progress] of one full tile (twice the width,
/// matching [_flowingGradient]).
class _SlideGradient extends GradientTransform {
  final double progress;

  const _SlideGradient(this.progress);

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(-bounds.width * 2 * progress, 0, 0);
}

/// 抽1次 · 連抽10 · 連抽100, each off while the remaining stock can't cover
/// it; one 已售罄 button once sold out. [onDraw] gets how many to draw.
class MainProductDrawButtons extends StatelessWidget {
  final MainProductModel product;
  final ValueChanged<int>? onDraw;

  const MainProductDrawButtons({required this.product, this.onDraw, super.key});

  static const Color _disabled = Color(0xFFDBE2EB);

  @override
  Widget build(BuildContext context) {
    if (product.isSoldOut) {
      return _button(context.tr(AppStrings.soldOut));
    }

    return Row(
      children: [
        Expanded(child: _draw(context, 1, AppColors.blackColor)),
        6.widthSpace,
        Expanded(child: _draw(context, 10, context.color.primary)),
        6.widthSpace,
        Expanded(child: _draw(context, 100, context.color.primary)),
      ],
    );
  }

  Widget _draw(BuildContext context, int count, Color color) {
    final bool enabled =
        onDraw != null && product.canDraw && product.remainingDraws >= count;

    return _button(
      count == 1
          ? context.tr(AppStrings.drawOnce)
          : context.tr(AppStrings.drawMulti, args: ['$count']),
      color: color,
      onTap: enabled ? () => onDraw!(count) : null,
    );
  }

  Widget _button(String text, {Color? color, VoidCallback? onTap}) {
    return AppButtonWidget(
      text: text,
      buttonColor: color,
      disabledColor: _disabled,
      radius: 10,
      textSize: kFont14,
      textColor: AppColors.whiteColor,
      onTap: onTap,
    );
  }
}
