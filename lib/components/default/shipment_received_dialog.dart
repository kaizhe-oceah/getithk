// Project imports:
import '../../imports.dart';

/// 您的出貨申請已成功收到: when the shipment should arrive, with a ✕ at the
/// top right and 確定 at the bottom; either closes it.
class ShipmentReceivedDialog extends StatelessWidget {
  const ShipmentReceivedDialog({super.key});

  /// Shows it; done once it's closed.
  static Future<void> show(BuildContext context) {
    return DialogHelper<void>().showDefaultDialog(
      context2: context,
      barrierDismissible: false,
      child: const ShipmentReceivedDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.whiteColor,
      surfaceTintColor: AppColors.transparentColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40).r,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16).r),
      child: Padding(
        // less on the right, where the ✕ has its own padding
        padding: const EdgeInsets.fromLTRB(20, 16, 14, 22).r,
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
                      context.tr(AppStrings.shipmentReceivedTitle),
                      fontSize: kFont16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                InkWellWrapper(
                  onTap: () => AppNavigator.pop(context),
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
                    context.tr(AppStrings.shipmentReceivedDescription),
                    fontSize: kFont14,
                    height: 1.5,
                  ),
                  10.heightSpace,
                  AppText(
                    context.tr(AppStrings.shipmentReceivedNote),
                    fontSize: kFont12,
                    color: AppColors.loginHintColor,
                    height: 1.5,
                  ),
                ],
              ),
            ),
            22.heightSpace,
            Center(
              child: SizedBox(
                width: 180.r,
                child: AppButtonWidget(
                  text: context.tr(AppStrings.okay),
                  radius: 12,
                  fontWeight: FontWeight.w600,
                  textColor: AppColors.whiteColor,
                  gradient: AppColors.brandGradientColor,
                  padding: const EdgeInsets.symmetric(vertical: 12).r,
                  onTap: () => AppNavigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
