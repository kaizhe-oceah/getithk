// Project imports:
import '../../imports.dart';
import '../../models/draw_result_model.dart';
import '../main_product/main_product_parts.dart';
import 'prize_dialog.dart';

/// Congratulations: what came out of a top-up reward box. A tap outside
/// closes it.
class AccumulateBoxRewardDialog extends StatelessWidget {
  final DrawHistoryModel prize;

  const AccumulateBoxRewardDialog({required this.prize, super.key});

  static const double _headerAspectRatio = 1663 / 945;

  static Future<void> show(BuildContext context, DrawHistoryModel prize) {
    return DialogHelper<void>().showDefaultDialog(
      context2: context,
      child: AccumulateBoxRewardDialog(prize: prize),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DrawSubProductModel? product = prize.subProduct;
    final String name = product?.name ?? '';
    final int cacheWidth =
        (MediaQuery.sizeOf(context).width *
                MediaQuery.devicePixelRatioOf(context))
            .round();

    return Dialog(
      backgroundColor: AppColors.whiteColor,
      surfaceTintColor: AppColors.transparentColor,
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40).r,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16).r),
      child: Stack(
        children: [
          Positioned.fill(
            child: AppImage(
              name: AppAssets.congratulationsBackground,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 8.r, bottom: 22.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _header(context, cacheWidth),
                12.heightSpace,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40).r,
                  child: PrizePicture(
                    image: product?.image,
                    isPsa10: product?.isPsa10 ?? false,
                    maxHeight: MediaQuery.sizeOf(context).height * 0.4,
                  ),
                ),
                if (name.isNotEmpty) ...[
                  16.heightSpace,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16).r,
                    child: AppText(
                      name,
                      fontSize: kFont16,
                      fontWeight: FontWeight.w700,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                6.heightSpace,
                AppText(
                  '${formatMainProductAmount(prize.amount)} PTS',
                  fontSize: kFont16,
                  fontWeight: FontWeight.w700,
                  color: context.color.primary,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, int cacheWidth) {
    final Color primary = context.color.primary;

    return Stack(
      alignment: Alignment.center,
      children: [
        // the image's empty top and bottom cut off
        ClipRect(
          child: Align(
            alignment: const Alignment(0, 0.07),
            heightFactor: 0.57,
            child: AspectRatio(
              aspectRatio: _headerAspectRatio,
              child: AppImage(
                name: AppAssets.congratulationsHeader,
                fit: BoxFit.contain,
                cacheWidth: cacheWidth,
              ),
            ),
          ),
        ),
        FractionallySizedBox(
          widthFactor: 0.66,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [AppColors.orangeColor, primary],
                  ).createShader(bounds),
                  // room for the italic's slant, inside the gradient
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.r),
                    child: AppText(
                      context.tr(AppStrings.congratulations),
                      fontSize: kFont26,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
              4.heightSpace,
              AppText(
                context.tr(AppStrings.upgradeRewardClaimed),
                fontSize: kFont13,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
