// Project imports:
import '../../imports.dart';

class AppBarBackButton extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final Color? buttonColor;
  final double? radius;
  final EdgeInsets? padding;
  final Function()? onTap;

  const AppBarBackButton({
    super.key,
    this.icon,
    this.iconColor,
    this.buttonColor,
    this.radius,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWellWrapper(
      onTap:
          onTap ??
          () {
            AppNavigator.pop(context);
          },
      child: Container(
        margin: padding ?? const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: buttonColor ?? AppColors.transparentColor,
          borderRadius: BorderRadius.circular(radius ?? 0.0).r,
        ),
        child: Icon(
          icon ?? Iconsax.arrow_left_copy,
          color: iconColor ?? context.color.onSurface,
          size: kToolbarHeight * 0.35,
        ),
      ),
    );
  }
}
