// Project imports:
import '../imports.dart';

/// The player's balance in a pill: a coin, 2,399,999.90 pts, and a + to top
/// up. For app bars, once logged in.
class PointsPill extends StatelessWidget {
  const PointsPill({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primary = context.color.primary;
    final double points = context.watch<AppController>().points;
    final double coinSize = 22.r;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4).r,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: primary),
      ),
      child: Row(
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
          AppText(
            '${NumberFormat('#,##0.00').format(points)} pts',
            fontSize: kFont13,
            fontWeight: FontWeight.w700,
            color: AppColors.loginTextColor,
          ),
          6.widthSpace,

          // top up
          InkWellWrapper(
            onTap: () =>
                ToastHelper.showToast(context.tr(AppStrings.comingSoon)),
            child: Container(
              width: 20.r,
              height: 20.r,
              decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
              child: Icon(
                Iconsax.add_copy,
                size: 14.r,
                color: AppColors.whiteColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
