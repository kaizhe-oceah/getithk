// Project imports:
import '../../imports.dart';
import '../../models/main_product_model.dart';

String formatMainProductAmount(double value) =>
    NumberFormat('#,##0.##').format(value);

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
    // a light color (e.g. "Free", #FFF700) barely shows on white: a stronger
    // tint of it, and its text darkened until it reads; the outline and tint
    // stay the API's color
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

  /// [color], same hue, darkened just enough to read as text on white
  /// (about 3:1 contrast); dark enough colors come back unchanged.
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
        _price(context),
        16.widthSpace,
        Expanded(child: _stock(context)),
      ],
    );
  }

  Widget _price(BuildContext context) {
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

  Widget _stock(BuildContext context) {
    final Color primary = context.color.primary;
    final double left = product.totalDraws > 0
        ? (product.remainingDraws / product.totalDraws).clamp(0.0, 1.0)
        : 0;

    return Column(
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
          height: 10.r,
          padding: const EdgeInsets.all(1.5).r,
          decoration: BoxDecoration(
            color: primary.wOpacity(0.1),
            border: Border.all(color: primary.wOpacity(0.25)),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: left,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: primary,
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

class MainProductTopupUnlock extends StatelessWidget {
  final MainProductModel product;

  const MainProductTopupUnlock({required this.product, super.key});

  static const Color _background = Color(0xFFF6F4FF);
  static const Color _border = Color(0xFFDCD5F7);
  static const Color _blue = Color(0xFF1E7BF2);
  static const LinearGradient _ribbonGradient = LinearGradient(
    colors: [Color(0xFF1E7BF2), Color(0xFFE6248C)],
  );
  static const LinearGradient _amountGradient = LinearGradient(
    colors: [Color(0xFF2F6BFF), Color(0xFFA334D6)],
  );

  @override
  Widget build(BuildContext context) {
    final int? left = product.remainingUnlockedDraws;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _background,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(10).r,
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
                        fontWeight: FontWeight.w700,
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
                      valueColor: _blue,
                    ),
                    6.heightSpace,
                    _info(
                      context.tr(AppStrings.chanceToGet),
                      left == null
                          ? context.tr(AppStrings.unlimited)
                          : context.tr(AppStrings.drawTimes, args: ['$left']),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ribbon(BuildContext context) {
    return ClipPath(
      clipper: const _ArrowTipClipper(),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 4, 18, 4).r,
        decoration: const BoxDecoration(gradient: _ribbonGradient),
        child: AppText(
          context.tr(
            AppStrings.topupPerDraw,
            args: [formatMainProductAmount(product.topupPerDraw ?? 0)],
          ),
          fontSize: kFont12,
          fontWeight: FontWeight.w700,
          color: AppColors.whiteColor,
        ),
      ),
    );
  }

  Widget _amount(double value) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: _amountGradient.createShader,
      child: Text.rich(
        TextSpan(
          style: const TextStyle(fontWeight: FontWeight.w800),
          children: [
            TextSpan(
              text: formatMainProductAmount(value),
              style: TextStyle(fontSize: kFont26.sp),
            ),
            TextSpan(
              text: ' pt',
              style: TextStyle(fontSize: kFont14.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String value, {Color? valueColor}) {
    return Text.rich(
      TextSpan(
        style: TextStyle(fontSize: kFont13.sp, color: AppColors.loginTextColor),
        children: [
          TextSpan(text: label),
          TextSpan(
            text: value,
            style: TextStyle(fontWeight: FontWeight.w700, color: valueColor),
          ),
        ],
      ),
    );
  }
}

class _ArrowTipClipper extends CustomClipper<Path> {
  const _ArrowTipClipper();

  @override
  Path getClip(Size size) {
    final double tip = size.height * 0.4;

    return Path()
      ..lineTo(size.width - tip, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width - tip, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(_ArrowTipClipper oldClipper) => false;
}

class MainProductDrawButton extends StatelessWidget {
  final MainProductModel product;
  final VoidCallback? onDraw;

  const MainProductDrawButton({required this.product, this.onDraw, super.key});

  @override
  Widget build(BuildContext context) {
    return AppButtonWidget(
      text: context.tr(
        product.isSoldOut ? AppStrings.soldOut : AppStrings.draw,
      ),
      radius: 10,
      textSize: kFont15,
      textColor: AppColors.whiteColor,
      onTap: product.canDraw ? onDraw : null,
    );
  }
}
