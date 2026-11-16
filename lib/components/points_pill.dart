// Project imports:
import '../imports.dart';

class PointsPill extends StatelessWidget {
  const PointsPill({super.key});

  @override
  Widget build(BuildContext context) {
    final double points = context.watch<AppController>().points;
    final double height = 32.r;
    final double coinSize = 22.r;
    final double addSize = 22.r;
    final double inset = (height - addSize) / 2;

    return InkWellWrapper(
      pressedScale: 0.95,
      onTap: () => AppNavigator.pushNamed(context, RouteName.topupPage),
      child: Container(
        height: height,
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.55,
        ),
        padding: EdgeInsets.symmetric(horizontal: inset),
        decoration: BoxDecoration(
          color: context.color.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: context.isDark
                ? AppColors.darkModeBorderColor
                : AppColors.greyLightColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppImage(
              name: AppAssets.coins,
              width: coinSize,
              height: coinSize,
              fit: BoxFit.contain,
            ),
            6.widthSpace,
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: AppText(
                  NumberFormat('#,##0.00').format(points),
                  fontSize: kFont14,
                  fontWeight: FontWeight.w700,
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
                size: 15.r,
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
