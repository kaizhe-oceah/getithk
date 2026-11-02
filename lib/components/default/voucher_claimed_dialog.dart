// Project imports:
import '../../imports.dart';

class VoucherClaimedDialog extends StatelessWidget {
  final double? points;

  // shown in place of the points line when there are no points
  final String? message;

  const VoucherClaimedDialog({this.points, this.message, super.key});

  static Future<void> show(
    BuildContext context, {
    double? points,
    String? message,
  }) {
    return DialogHelper<void>().showDefaultDialog(
      context2: context,
      child: VoucherClaimedDialog(points: points, message: message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double imageSize = 140.r;

    return Dialog(
      backgroundColor: AppColors.whiteColor,
      surfaceTintColor: AppColors.transparentColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40).r,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16).r),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 28, 24).r,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: AppImage(
                    name: AppAssets.claimDialogHeader,
                    width: imageSize,
                    height: imageSize,
                    cacheWidth:
                        (imageSize * MediaQuery.devicePixelRatioOf(context))
                            .round(),
                  ),
                ),
                AppText(
                  context.tr(AppStrings.claimSuccess),
                  fontSize: kFont18,
                  fontWeight: FontWeight.w700,
                  textAlign: TextAlign.center,
                ),
                12.heightSpace,
                _description(context),
                24.heightSpace,
                AppButtonWidget(
                  text: context.tr(AppStrings.okay),
                  radius: 12,
                  textSize: kFont15,
                  fontWeight: FontWeight.w600,
                  textColor: AppColors.whiteColor,
                  padding: const EdgeInsets.symmetric(vertical: 14).r,
                  onTap: () => AppNavigator.pop(context),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8.r,
            right: 8.r,
            child: InkWellWrapper(
              onTap: () => AppNavigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.all(6).r,
                child: Icon(
                  Icons.close_rounded,
                  size: 24.r,
                  color: AppColors.loginTextColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 恭喜您獲得 **2,000** 積分，已成功存入您的帳戶。
  Widget _description(BuildContext context) {
    final double? value = points;
    if (value == null || value <= 0) {
      final String text = message ?? '';
      if (text.isEmpty) return const SizedBox.shrink();

      return AppText(
        text,
        fontSize: kFont15,
        textAlign: TextAlign.center,
        height: 1.6,
      );
    }

    final TextStyle style = TextStyle(
      fontSize: kFont15.sp,
      height: 1.6,
      color: context.color.onSurface,
    );
    final List<String> parts = context
        .tr(AppStrings.voucherClaimedPoints)
        .split('{}');

    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: parts.first),
          TextSpan(
            text: NumberFormat('#,##0.##').format(value),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          if (parts.length > 1) TextSpan(text: parts.sublist(1).join()),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
