// Project imports:
import '../../imports.dart';
import '../../models/main_product_model.dart';
import '../../utils/draw_helper.dart';
import 'main_product_parts.dart';

class MainProductTrialDialog extends StatelessWidget {
  final MainProductModel product;

  const MainProductTrialDialog({required this.product, super.key});

  static Future<void> show(BuildContext context, MainProductModel product) {
    return DialogHelper<void>().showDefaultDialog(
      context2: context,
      child: MainProductTrialDialog(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.whiteColor,
      surfaceTintColor: AppColors.transparentColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40).r,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20).r),
      child: Padding(
        padding: const EdgeInsets.all(20).r,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppText(
                    context.tr(AppStrings.trialDialogTitle),
                    fontSize: kFont18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.loginTextColor,
                  ),
                ),
                InkWellWrapper(
                  onTap: () => AppNavigator.pop(context),
                  child: Icon(
                    Icons.close_rounded,
                    size: 24.r,
                    color: AppColors.loginTextColor,
                  ),
                ),
              ],
            ),
            6.heightSpace,
            AppText(
              context.tr(AppStrings.trialDialogMessage),
              fontSize: kFont13,
              color: AppColors.textLightColor,
            ),
            16.heightSpace,
            _picture(context),
            20.heightSpace,
            _buttons(context),
          ],
        ),
      ),
    );
  }

  Widget _picture(BuildContext context) {
    // the picture at its own aspect ratio, as on the product card: nothing
    // cropped off
    return ClipRRect(
      borderRadius: BorderRadius.circular(12).r,
      child: Stack(
        children: [
          MainProductImage(image: product.image),
          Positioned(
            top: 8.r,
            left: 8.r,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 3,
              ).r,
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(100),
              ),
              child: AppText(
                context.tr(AppStrings.trialVersion),
                fontSize: kFont11,
                fontWeight: FontWeight.w700,
                color: AppColors.loginTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 抽1次 (outlined) and 連抽10 (filled), each with a 免費 badge.
  Widget _buttons(BuildContext context) {
    final Color primary = context.color.primary;
    final EdgeInsets padding = const EdgeInsets.symmetric(vertical: 12).r;

    return Row(
      children: [
        Expanded(
          child: _freeBadge(
            context,
            color: primary,
            textColor: AppColors.whiteColor,
            child: AppButtonWidget(
              text: context.tr(AppStrings.drawOnce),
              radius: 10,
              textSize: kFont14,
              buttonColor: AppColors.whiteColor,
              borderColor: primary,
              textColor: primary,
              padding: padding,
              onTap: () => DrawHelper.trialDrawProduct(product, 1),
            ),
          ),
        ),
        12.widthSpace,
        Expanded(
          child: _freeBadge(
            context,
            color: AppColors.whiteColor,
            textColor: primary,
            child: AppButtonWidget(
              text: context.tr(AppStrings.drawMulti, args: ['10']),
              radius: 10,
              textSize: kFont14,
              textColor: AppColors.whiteColor,
              padding: padding,
              onTap: () => DrawHelper.trialDrawProduct(product, 10),
            ),
          ),
        ),
      ],
    );
  }

  /// [child] with a 免費 badge on its top right corner.
  Widget _freeBadge(
    BuildContext context, {
    required Color color,
    required Color textColor,
    required Widget child,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -8.r,
          right: 10.r,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1).r,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blackColor.wOpacity(0.08),
                  blurRadius: 4.r,
                ),
              ],
            ),
            child: AppText(
              context.tr(AppStrings.free),
              fontSize: kFont10,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}
