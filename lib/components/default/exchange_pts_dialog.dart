// Project imports:
import '../../imports.dart';
import '../../models/shipment_item_model.dart';
import '../main_product/main_product_parts.dart';

class ExchangePtsDialog extends StatelessWidget {
  final double amount;

  const ExchangePtsDialog({required this.amount, super.key});
  static Future<bool> show(
    BuildContext context, {
    required List<ShipmentItemModel> items,
  }) async {
    context.read<AppController>().getWalletBalance();

    final bool? confirmed = await DialogHelper<bool>().showDefaultDialog(
      context2: context,
      child: ExchangePtsDialog(
        amount: items.fold(0, (double sum, item) => sum + item.totalAmount),
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final double points = context.watch<AppController>().points;

    return Dialog(
      backgroundColor: AppColors.whiteColor,
      surfaceTintColor: AppColors.transparentColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40).r,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16).r),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 14, 20).r,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 4.r),
                    child: AppText(
                      context.tr(AppStrings.exchangePts),
                      fontSize: kFont16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                InkWellWrapper(
                  onTap: () => AppNavigator.pop(context, false),
                  child: Padding(
                    padding: const EdgeInsets.all(4).r,
                    child: Icon(
                      Icons.close_rounded,
                      size: 22.r,
                      color: AppColors.loginTextColor,
                    ),
                  ),
                ),
              ],
            ),
            12.heightSpace,
            Padding(
              padding: EdgeInsets.only(right: 6.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppText(
                    context.tr(AppStrings.exchangePtsDescription),
                    fontSize: kFont12,
                  ),
                  16.heightSpace,
                  _balance(context, points),
                  20.heightSpace,
                  AppButtonWidget(
                    text: context.tr(AppStrings.decide),
                    radius: 10,
                    fontWeight: FontWeight.w600,
                    textColor: AppColors.whiteColor,
                    padding: const EdgeInsets.symmetric(vertical: 10).r,
                    onTap: () => AppNavigator.pop(context, true),
                  ),
                  10.heightSpace,
                  AppButtonWidget(
                    text: context.tr(AppStrings.cancel),
                    radius: 10,
                    fontWeight: FontWeight.w600,
                    buttonColor: AppColors.whiteColor,
                    borderColor: AppColors.greyLightColor,
                    textColor: AppColors.loginTextColor,
                    padding: const EdgeInsets.symmetric(vertical: 10).r,
                    onTap: () => AppNavigator.pop(context, false),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _balance(BuildContext context, double points) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14).r,
      decoration: BoxDecoration(
        color: AppColors.greyBackgroundColor,
        borderRadius: BorderRadius.circular(10).r,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _amount(context, points),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10).r,
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 16.r,
                color: AppColors.loginHintColor,
              ),
            ),
            _amount(context, points + amount, color: AppColors.successGreen),
          ],
        ),
      ),
    );
  }

  Widget _amount(BuildContext context, double value, {Color? color}) {
    final double coinSize = 20.r;

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
        6.widthSpace,
        AppText(
          formatMainProductAmount(value),
          fontSize: kFont14,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ],
    );
  }
}
