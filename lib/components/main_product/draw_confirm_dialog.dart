// Project imports:
import '../../imports.dart';
import '../../models/main_product_model.dart';
import 'main_product_parts.dart';

/// 確認抽卡: the product's banner, how many draws, then the balance now ＞
/// after paying for them. Only shown when the balance covers it (else
/// DrawHelper shows 點數不夠). Pops true once confirmed.
class DrawConfirmDialog extends StatelessWidget {
  final MainProductModel product;
  final int count;

  const DrawConfirmDialog({
    required this.product,
    required this.count,
    super.key,
  });

  /// True once 確認抽卡 is tapped.
  static Future<bool?> show(
    BuildContext context, {
    required MainProductModel product,
    required int count,
  }) {
    return DialogHelper<bool>().showDefaultDialog(
      context2: context,
      child: DrawConfirmDialog(product: product, count: count),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double balance = context.watch<AppController>().points;
    final double after = balance - product.drawAmount * count;
    final Color primary = context.color.primary;

    return Dialog(
      backgroundColor: AppColors.whiteColor,
      surfaceTintColor: AppColors.transparentColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40).r,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16).r),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16).r,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppImage(name: product.image, fit: BoxFit.contain, radius: 10),
            16.heightSpace,
            AppText(
              context.tr(AppStrings.confirmDraw),
              fontSize: kFont15,
              fontWeight: FontWeight.w700,
              textAlign: TextAlign.center,
            ),
            6.heightSpace,
            AppText(
              context.tr(
                AppStrings.confirmDrawMessage,
                namedArgs: {
                  'name': product.name ?? product.categoryName ?? '',
                  'count': '$count',
                },
              ),
              fontSize: kFont12,
              color: AppColors.textLightColor,
              textAlign: TextAlign.center,
            ),
            14.heightSpace,
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ).r,
              decoration: BoxDecoration(
                color: AppColors.greyBackgroundColor,
                borderRadius: BorderRadius.circular(12).r,
              ),
              // long amounts shrink, all together, instead of overflowing
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _coinAmount(context, balance, AppColors.loginTextColor),
                    12.widthSpace,
                    Icon(
                      Iconsax.arrow_right_3_copy,
                      size: 16.r,
                      color: AppColors.loginHintColor,
                    ),
                    12.widthSpace,
                    _coinAmount(context, after, primary),
                  ],
                ),
              ),
            ),
            18.heightSpace,
            Row(
              children: [
                Expanded(
                  // as 點數不夠's (DrawHelper): grey, then primary
                  child: AppButtonWidget(
                    radius: 10,
                    text: context.tr(AppStrings.cancel),
                    buttonColor: AppColors.greyBackgroundColor,
                    textColor: AppColors.loginTextColor,
                    onTap: () => AppNavigator.pop(context, false),
                  ),
                ),
                10.widthSpace,
                Expanded(
                  child: AppButtonWidget(
                    radius: 10,
                    text: context.tr(AppStrings.confirmDraw),
                    buttonColor: primary,
                    textColor: AppColors.whiteColor,
                    onTap: () => AppNavigator.pop(context, true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// [amount] pts after a coin, in [color].
  Widget _coinAmount(BuildContext context, double amount, Color color) {
    final double coinSize = 22.r;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppImage(
          name: AppAssets.coins,
          width: coinSize,
          height: coinSize,
          fit: BoxFit.contain,
        ),
        6.widthSpace,
        AppText(
          formatMainProductAmount(amount),
          fontSize: kFont15,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ],
    );
  }
}
