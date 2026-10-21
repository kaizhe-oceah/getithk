// Project imports:
import '../imports.dart';

class PointsPill extends StatelessWidget {
  const PointsPill({super.key});

  @override
  Widget build(BuildContext context) {
    final double points = context.watch<AppController>().points;
    final double height = 30.r;
    final double addSize = 22.r;

    return InkWellWrapper(
      onTap: () => AppNavigator.pushNamed(context, RouteName.topupPage),
      child: Container(
        height: height,
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.55,
        ),
        padding: EdgeInsets.only(right: (height - addSize) / 2),
        decoration: BoxDecoration(
          color: AppColors.greyLight2Color,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppImage(
              name: AppAssets.coins,
              width: height,
              height: height,
              fit: BoxFit.contain,
            ),
            6.widthSpace,
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: AppText(
                  NumberFormat('#,##0.00').format(points),
                  fontSize: kFont14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.loginTextColor,
                ),
              ),
            ),
            8.widthSpace,
            Container(
              width: addSize,
              height: addSize,
              decoration: BoxDecoration(
                color: context.color.primary,
                shape: BoxShape.circle,
              ),
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
