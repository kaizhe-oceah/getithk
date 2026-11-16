// Dart imports:
import 'dart:math' as math;
import 'dart:ui' as ui;

// Project imports:
import '../../imports.dart';
import '../../models/main_product_model.dart';
import 'main_product_trial_dialog.dart';

String formatMainProductAmount(double value) =>
    NumberFormat('#,##0.##').format(value);

// a card's main and secondary text, on white or on a dark card
Color _ink(BuildContext context) =>
    context.isDark ? AppColors.whiteColor : AppColors.loginTextColor;
Color _subtle(BuildContext context) =>
    context.isDark ? AppColors.darkModeHintColor : AppColors.textLightColor;

class MainProductImage extends StatelessWidget {
  final String? image;

  const MainProductImage({required this.image, super.key});

  static const double bannerAspectRatio = 1280 / 714;

  @override
  Widget build(BuildContext context) {
    return AppImage(
      name: image,
      width: double.infinity,
      fit: BoxFit.cover,
      // no height till it's in, so the skeleton takes the banner's shape
      placeholder: const AspectRatio(
        aspectRatio: bannerAspectRatio,
        child: AppSkeletonizer(child: Bone()),
      ),
    );
  }
}

class MainProductTags extends StatelessWidget {
  final List<MainProductTagModel> tags;
  final bool dense;

  const MainProductTags({required this.tags, this.dense = false, super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: (dense ? 4 : 6).r,
      runSpacing: (dense ? 4 : 6).r,
      children: [
        for (final MainProductTagModel tag in tags)
          if ((tag.name ?? '').isNotEmpty) _tag(context, tag),
      ],
    );
  }

  Widget _tag(BuildContext context, MainProductTagModel tag) {
    final Color color = tag.colorValue ?? AppColors.greyColor;
    final bool light = color.computeLuminance() > 0.55;
    final bool dark = context.isDark;
    final Color text = _readable(color, onDark: dark);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 7 : 10,
        vertical: dense ? 1 : 2,
      ).r,
      decoration: BoxDecoration(
        color: color.wOpacity(light ? 0.25 : 0.1),
        border: Border.all(color: dark ? text : color),
        borderRadius: BorderRadius.circular(100),
      ),
      child: AppText(
        tag.name!,
        fontSize: dense ? kFont10 : kFont12,
        fontWeight: FontWeight.w500,
        color: text,
      ),
    );
  }

  // darker on white, lighter on a dark card
  static Color _readable(Color color, {required bool onDark}) {
    HSLColor hsl = HSLColor.fromColor(color);
    bool readable() => onDark
        ? hsl.toColor().computeLuminance() >= 0.2 || hsl.lightness >= 1
        : hsl.toColor().computeLuminance() <= 0.3 || hsl.lightness <= 0;
    while (!readable()) {
      hsl = hsl.withLightness(
        (hsl.lightness + (onDark ? 0.02 : -0.02)).clamp(0.0, 1.0),
      );
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
                  color: _ink(context),
                ),
              ),
              TextSpan(
                text: ' ${context.tr(AppStrings.perDraw)}',
                style: TextStyle(fontSize: kFont12.sp, color: _subtle(context)),
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
  final CrossAxisAlignment alignment;

  const MainProductStock({
    required this.product,
    this.alignment = CrossAxisAlignment.end,
    super.key,
  });

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
      crossAxisAlignment: alignment,
      children: [
        // `is_show_quantity` hides only the count; the bar always shows
        if (product.isShowQuantity) ...[
          Text.rich(
            TextSpan(
              style: TextStyle(fontSize: kFont11.sp, color: _subtle(context)),
              children: [
                TextSpan(text: '${context.tr(AppStrings.remainingStock)} '),
                TextSpan(
                  text: '${product.remainingDraws}/${product.totalDraws}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _ink(context),
                  ),
                ),
              ],
            ),
          ),
          4.heightSpace,
        ],
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

  /// For a grid cell: the amount still to top up and the draws available
  /// now; the rest is on the product's page.
  final bool dense;

  const MainProductTopupUnlock({
    required this.product,
    this.dense = false,
    super.key,
  });

  @override
  State<MainProductTopupUnlock> createState() => _MainProductTopupUnlockState();
}

class _MainProductTopupUnlockState extends State<MainProductTopupUnlock>
    with SingleTickerProviderStateMixin {
  static const Duration _flowDuration = Duration(seconds: 6);
  static const double _borderWidth = 1.5;

  bool get _dark => context.isDark;

  // the brand red reads dim on charcoal, so dark mode lifts it
  Color get _primary => _dark
      ? Color.lerp(context.color.primary, AppColors.whiteColor, 0.3)!
      : context.color.primary;

  Color get _labelColor =>
      _dark ? AppColors.textLightColor : AppColors.loginHintColor;

  // the primary with a lighter band sweeping across it
  List<Color> get _flowColors => [
    _primary,
    Color.lerp(_primary, AppColors.whiteColor, 0.45)!,
    _primary,
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
    final bool dense = widget.dense;
    final double radius = (dense ? 10 : 12).r;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _flow,
        builder: (context, child) {
          final GradientRotation rotation = GradientRotation(
            2 * math.pi * _flow.value,
          );

          return Stack(
            children: [
              // the running light's glow, spilling past the border
              Positioned.fill(
                child: ImageFiltered(
                  imageFilter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(radius),
                      gradient: _runningLight(
                        rotation,
                        base: _primary.wOpacity(0),
                        light: _primary.wOpacity(_dark ? 0.3 : 0.55),
                      ),
                    ),
                  ),
                ),
              ),
              // the border itself: grey, with the light running round it
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  gradient: _runningLight(
                    rotation,
                    base: context.isDark
                        ? AppColors.darkModeBorderColor
                        : AppColors.greyLightColor,
                    light: _primary,
                  ),
                ),
                child: child,
              ),
            ],
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(_borderWidth),
          child: Container(
            padding: EdgeInsets.all(dense ? 8 : 12).r,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius - _borderWidth),
              // a soft wash of the primary, strongest at the top left; opaque,
              // so only the border and the glow outside it show the light
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.alphaBlend(
                    _primary.wOpacity(_dark ? 0.1 : 0.07),
                    context.color.surface,
                  ),
                  Color.alphaBlend(
                    _primary.wOpacity(_dark ? 0.02 : 0.01),
                    context.color.surface,
                  ),
                ],
              ),
            ),
            child: dense
                ? _denseContent(product)
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _amountBlock(product),
                          10.widthSpace,
                          Expanded(
                            child: Align(
                              alignment: Alignment.topRight,
                              child: _rule(product),
                            ),
                          ),
                        ],
                      ),
                      12.heightSpace,
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _stat(
                              label: context.tr(AppStrings.drawsAvailableNow),
                              times: product.availableDraws ?? 0,
                            ),
                            8.widthSpace,
                            _stat(
                              label: context.tr(AppStrings.remainingUnlock),
                              times: product.remainingUnlockedDraws,
                            ),
                            8.widthSpace,
                            _stat(
                              label: context.tr(AppStrings.chanceToGet),
                              times: product.maxUnlockTimes,
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

  Widget _denseContent(MainProductModel product) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(context.tr(AppStrings.topupMore)),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: _FlowingGradient(
            flow: _flow,
            colors: _flowColors,
            child: _amount(
              product.topupToNextUnlock ?? 0,
              fontSize: kFont18,
              unitSize: kFont11,
            ),
          ),
        ),
        6.heightSpace,
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(child: _label(context.tr(AppStrings.drawsAvailableNow))),
            4.widthSpace,
            _count(product.availableDraws ?? 0, fontSize: kFont13),
          ],
        ),
      ],
    );
  }

  Widget _label(String text) {
    return AppText(
      // the labels end in a colon ("現正可抽：") for inline use
      text.replaceFirst(RegExp(r'\s*[：:]\s*$'), ''),
      fontSize: kFont10,
      fontWeight: FontWeight.w500,
      color: _labelColor,
      maxLines: 1,
      isOverflow: true,
    );
  }

  // two lights chasing each other round the border, each fading in from
  // its tail to a bright head
  SweepGradient _runningLight(
    GradientRotation rotation, {
    required Color base,
    required Color light,
  }) {
    return SweepGradient(
      transform: rotation,
      colors: [base, base, light, base, base, light, base],
      stops: const [0, 0.15, 0.45, 0.5, 0.65, 0.95, 1],
    );
  }

  Widget _amountBlock(MainProductModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          context.tr(AppStrings.topupMore),
          fontSize: kFont12,
          fontWeight: FontWeight.w500,
          color: _labelColor,
        ),
        2.heightSpace,
        _FlowingGradient(
          flow: _flow,
          colors: _flowColors,
          child: _amount(product.topupToNextUnlock ?? 0),
        ),
      ],
    );
  }

  Widget _amount(
    double value, {
    double fontSize = kFont26,
    double unitSize = kFont14,
  }) {
    return Text.rich(
      TextSpan(
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: AppColors.whiteColor,
          height: 1.1,
        ),
        children: [
          TextSpan(
            text: formatMainProductAmount(value),
            style: TextStyle(fontSize: fontSize.sp),
          ),
          TextSpan(
            text: ' pt',
            style: TextStyle(fontSize: unitSize.sp),
          ),
        ],
      ),
    );
  }

  Widget _rule(MainProductModel product) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4).r,
      decoration: BoxDecoration(
        color: _primary.wOpacity(_dark ? 0.14 : 0.06),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: _primary.wOpacity(_dark ? 0.35 : 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 1.r),
            child: Icon(Iconsax.flash_1, size: 12.r, color: _primary),
          ),
          4.widthSpace,
          Flexible(
            child: AppText(
              context.tr(
                AppStrings.topupPerDraw,
                args: [formatMainProductAmount(product.topupPerDraw ?? 0)],
              ),
              fontSize: kFont11,
              fontWeight: FontWeight.w600,
              color: _primary,
              maxLines: 2,
              isOverflow: true,
            ),
          ),
        ],
      ),
    );
  }

  // the number in the flowing primary, the rest ("次") in black; null is
  // unlimited, all of it flowing
  Widget _count(int? times, {double fontSize = kFont16}) {
    Widget flowing(String text) => _FlowingGradient(
      flow: _flow,
      colors: _flowColors,
      child: _countText(text, fontSize: fontSize),
    );

    if (times == null) return flowing(context.tr(AppStrings.unlimited));

    final String number = '$times';
    final String text = context.tr(AppStrings.drawTimes, args: [number]);
    final int at = text.indexOf(number);
    if (at < 0) return flowing(text);

    final String before = text.substring(0, at);
    final String after = text.substring(at + number.length);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        if (before.isNotEmpty)
          _countText(before, fontSize: fontSize, color: _primary),
        flowing(number),
        if (after.isNotEmpty)
          _countText(after, fontSize: fontSize, color: _primary),
      ],
    );
  }

  Widget _countText(String text, {required double fontSize, Color? color}) {
    return AppText(
      text,
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      color: color,
      maxLines: 1,
    );
  }

  Widget _stat({required String label, required int? times}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 9, 8, 9).r,
        decoration: BoxDecoration(
          color: _dark ? AppColors.darkModeRaisedColor : context.color.surface,
          borderRadius: BorderRadius.circular(12).r,
          boxShadow: _dark
              ? null
              : [
                  BoxShadow(
                    color: AppColors.blackColor.wOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // shrinks a long value ("Tanpa had") rather than cutting it
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: _count(times),
            ),
            3.heightSpace,
            AppText(
              // the labels end in a colon ("現正可抽：") for inline use
              label.replaceFirst(RegExp(r'\s*[：:]\s*$'), ''),
              fontSize: kFont11,
              color: _labelColor,
              maxLines: 2,
              isOverflow: true,
            ),
          ],
        ),
      ),
    );
  }
}

LinearGradient _flowingGradient(List<Color> colors, double progress) {
  return LinearGradient(
    end: const Alignment(3, 0),
    colors: colors,
    tileMode: TileMode.repeated,
    transform: _SlideGradient(progress),
  );
}

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

class _SlideGradient extends GradientTransform {
  final double progress;

  const _SlideGradient(this.progress);

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(-bounds.width * 2 * progress, 0, 0);
}

class MainProductDrawButtons extends StatelessWidget {
  final MainProductModel product;
  final ValueChanged<int>? onDraw;
  final VoidCallback? onTopUp;

  /// For a grid cell: smaller buttons, and 1 and 10 draws only; the
  /// product's page has 100.
  final bool dense;

  const MainProductDrawButtons({
    required this.product,
    this.onDraw,
    this.onTopUp,
    this.dense = false,
    super.key,
  });

  static const Color _disabled = Color(0xFFDBE2EB);

  // 抽1次: black on white, white on a dark card
  static Color _plain(BuildContext context) =>
      context.isDark ? AppColors.whiteColor : AppColors.blackColor;

  @override
  Widget build(BuildContext context) {
    if (!product.isAvailable || product.isSoldOut) {
      return _button(
        context,
        context.tr(
          product.isSoldOut ? AppStrings.soldOut : AppStrings.drawUnavailable,
        ),
      );
    }

    // logged out: either opens the login page (the button checks); a top-up
    // unlock product is drawn by topping up, so 購買點數
    if (context.watch<AppController>().user == null) {
      if (product.hasTopupUnlock) return _buyPointsButton(context);
      return product.isTrialDraw
          ? _trialButtons(context)
          : _drawLotsButton(context);
    }

    if (product.hasTopupUnlock && (product.availableDraws ?? 0) <= 0) {
      return _buyPointsButton(context);
    }

    return Row(
      children: [
        Expanded(child: _draw(context, 1, _plain(context))),
        6.widthSpace,
        Expanded(child: _draw(context, 10, context.color.primary)),
        if (!dense) ...[
          6.widthSpace,
          Expanded(child: _draw(context, 100, context.color.primary)),
        ],
      ],
    );
  }

  Widget _buyPointsButton(BuildContext context) {
    return _button(
      context,
      context.tr(AppStrings.buyPoints),
      color: context.color.primary,
      onTap: () async {
        await AppNavigator.pushNamed(context, RouteName.topupPage);
        onTopUp?.call();
      },
    );
  }

  Widget _drawLotsButton(BuildContext context) {
    return _button(
      context,
      context.tr(AppStrings.drawLots),
      color: context.color.primary,
      onTap: () => onDraw?.call(1),
    );
  }

  Widget _trialButtons(BuildContext context) {
    final Color primary = context.color.primary;

    return Row(
      children: [
        Expanded(child: _drawLotsButton(context)),
        (dense ? 6 : 10).widthSpace,
        Expanded(
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              AppButtonWidget(
                buttonColor: context.color.surface,
                borderColor: primary,
                radius: _radius,
                padding: _padding,
                onTap: () => MainProductTrialDialog.show(context, product),
                builder: _label(
                  context.tr(AppStrings.trialDraw),
                  fontSize: dense ? kFont12 : kFont14,
                  color: primary,
                ),
              ),
              Positioned(
                top: -8.r,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 1,
                  ).r,
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: AppText(
                    context.tr(AppStrings.free),
                    fontSize: kFont10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.whiteColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _draw(BuildContext context, int count, Color color) {
    final int limit =
        product.hasTopupUnlock &&
            (product.availableDraws ?? 0) < product.remainingDraws
        ? product.availableDraws ?? 0
        : product.remainingDraws;
    final bool enabled = onDraw != null && count <= limit;

    return _button(
      context,
      count == 1
          ? context.tr(AppStrings.drawOnce)
          : context.tr(AppStrings.drawMulti, args: ['$count']),
      color: color,
      onTap: enabled ? () => onDraw!(count) : null,
    );
  }

  double get _radius => dense ? 8 : 10;

  EdgeInsets? get _padding =>
      dense ? const EdgeInsets.symmetric(horizontal: 6, vertical: 7).r : null;

  Widget _button(
    BuildContext context,
    String text, {
    Color? color,
    VoidCallback? onTap,
  }) {
    final bool dark = context.isDark;
    final Color label = onTap == null
        ? (dark ? AppColors.darkModeHintColor : AppColors.whiteColor)
        : color == AppColors.whiteColor
        ? AppColors.blackColor
        : AppColors.whiteColor;

    return AppButtonWidget(
      buttonColor: color,
      disabledColor: dark ? AppColors.darkModeBorderColor : _disabled,
      radius: _radius,
      padding: _padding,
      checkLogin: true,
      onTap: onTap,
      builder: _label(text, fontSize: dense ? kFont12 : kFont13, color: label),
    );
  }

  // shrinks a long label ("Belum Boleh Dicabut") to the button's width
  Widget _label(String text, {required double fontSize, required Color color}) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: AppText(
          text,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: color,
          maxLines: 1,
        ),
      ),
    );
  }
}
