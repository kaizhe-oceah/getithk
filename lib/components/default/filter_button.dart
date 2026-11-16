// Project imports:
import '../../imports.dart';

/// 篩選: a grey chip, tinted with the primary and showing [count] once any
/// filter is on.
class FilterButton extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const FilterButton({required this.count, required this.onTap, super.key});

  static EdgeInsets get padding =>
      const EdgeInsets.symmetric(horizontal: 12, vertical: 6).r;
  static const double radius = 10;
  static const FontWeight fontWeight = FontWeight.w600;

  static Color backgroundColor(BuildContext context) => context.isDark
      ? AppColors.darkModeSurfaceColor
      : AppColors.greyBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final Color primary = context.color.primary;
    final bool filtered = count > 0;

    return InkWellWrapper(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: filtered ? primary.wOpacity(0.08) : backgroundColor(context),
          borderRadius: BorderRadius.circular(radius).r,
          // as tall as a dropdown beside it, which has a border
          border: Border.all(
            color: filtered
                ? primary.wOpacity(0.2)
                : AppColors.transparentColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.setting_4_copy,
              size: 15.r,
              color: filtered ? primary : context.color.onSurface,
            ),
            5.widthSpace,
            AppText(
              context.tr(AppStrings.filter),
              fontSize: kFont12,
              fontWeight: fontWeight,
              color: filtered ? primary : null,
            ),
            if (filtered) ...[5.widthSpace, _count(primary)],
          ],
        ),
      ),
    );
  }

  Widget _count(Color primary) {
    return Container(
      constraints: BoxConstraints(minWidth: 16.r),
      height: 16.r,
      padding: EdgeInsets.symmetric(horizontal: 4.r),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(100),
      ),
      child: AppText(
        '$count',
        fontSize: kFont10,
        fontWeight: FontWeight.w700,
        color: AppColors.whiteColor,
      ),
    );
  }
}
