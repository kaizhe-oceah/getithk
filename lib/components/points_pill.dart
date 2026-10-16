// Project imports:
import '../imports.dart';

class PointsPill extends StatelessWidget {
  const PointsPill({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primary = context.color.primary;
    final double points = context.watch<AppController>().points;
    final double coinSize = 22.r;

    // all of it opens the top up page
    return InkWellWrapper(
      onTap: () => AppNavigator.pushNamed(context, RouteName.topupPage),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.55,
        ),
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
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: AppText(
                  NumberFormat('#,##0.00').format(points),
                  fontSize: kFont13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.loginTextColor,
                ),
              ),
            ),
            5.widthSpace,
            Container(
              width: 20.r,
              height: 20.r,
              decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
              child: Icon(
                Iconsax.add_copy,
                size: 16.r,
                color: AppColors.whiteColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
