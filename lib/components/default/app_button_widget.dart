// Project imports:
import '../../imports.dart';

class AppButtonWidget extends StatelessWidget {
  final Function()? onTap;
  final String? text;
  final EdgeInsetsGeometry? padding;
  final Color? textColor;

  /// Corner radius; defaults to [kDefaultRadius].
  final double? radius;
  final double? textSize;
  final FontWeight? fontWeight;
  final Widget? builder;
  final Color? buttonColor;

  /// Fill while [onTap] is null; defaults to [AppColors.disabledColor].
  final Color? disabledColor;
  final AlignmentGeometry? begin;
  final AlignmentGeometry? end;
  final List<double>? stops;
  final double? borderStroke;
  final bool textIgnoreLine;
  final Widget? icon;
  final Widget? iconRight;
  final bool checkLogin;
  final double? iconSpace;
  final bool isMinWidth;
  final Color? borderColor;
  final Duration cooldownDuration;
  final bool keyboardCheckingEnabled;
  final bool isGradient;

  /// Custom gradient, takes priority over [isGradient].
  final Gradient? gradient;
  final bool safeAreaEnabled;
  final double? width;
  final bool? isStickToWall;
  final BorderRadiusGeometry? borderRadiusBuilder;

  const AppButtonWidget({
    this.onTap,
    this.buttonColor,
    this.disabledColor,
    this.begin,
    this.end,
    this.stops,
    this.borderStroke,
    this.text,
    this.builder,
    this.padding,
    this.textColor,
    this.radius,
    this.textSize,
    this.fontWeight,
    this.textIgnoreLine = false,
    this.icon,
    this.iconRight,
    this.checkLogin = false,
    this.iconSpace,
    this.isMinWidth = false,
    this.borderColor,
    this.cooldownDuration = const Duration(milliseconds: 0),
    this.keyboardCheckingEnabled = false,
    this.isGradient = false,
    this.gradient,
    this.safeAreaEnabled = false,
    this.width,
    this.isStickToWall = false,
    this.borderRadiusBuilder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (safeAreaEnabled) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: isStickToWall == true
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(
                  horizontal: kHorizontalPadding,
                  vertical: 5,
                ).r,
          child: button(context),
        ),
      );
    }

    return button(context);
  }

  Widget button(BuildContext context) {
    return InkWellWrapper(
      checkLogin: checkLogin,
      cooldownDuration: cooldownDuration,
      keyboardCheckingEnabled: keyboardCheckingEnabled,
      onTap: onTap != null
          ? () {
              onTap!();
            }
          : null,
      child: Container(
        padding: padding ?? const EdgeInsets.symmetric(vertical: 8).r,
        width: width,
        decoration: onTap != null
            ? BoxDecoration(
                borderRadius:
                    borderRadiusBuilder ??
                    BorderRadius.circular(radius ?? kDefaultRadius).r,
                color: buttonColor ?? context.color.primary,
                gradient:
                    gradient ??
                    (isGradient ? AppColors.buttonGradientColor : null),
                border: Border.all(
                  color: borderColor ?? AppColors.transparentColor,
                  width: borderStroke ?? 1.0,
                ),
              )
            : BoxDecoration(
                borderRadius:
                    borderRadiusBuilder ??
                    BorderRadius.circular(radius ?? kDefaultRadius).r,
                color: disabledColor ?? AppColors.disabledColor,
                border: Border.all(
                  color: borderColor ?? AppColors.transparentColor,
                  width: borderStroke ?? 1.0,
                ),
              ),
        child: builder ?? _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final textWidget = AppText(
      text ?? "",
      fontSize: textSize,
      fontWeight: fontWeight ?? FontWeight.w600,
      color: onTap != null
          ? textColor ?? context.color.onPrimary
          : AppColors.whiteColor,
      isOverflow: textIgnoreLine,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: isMinWidth ? MainAxisSize.min : MainAxisSize.max,
      children: [
        if (icon != null)
          Padding(
            padding: EdgeInsets.only(right: iconSpace ?? 5).r,
            child: icon!,
          ),
        textWidget,
        if (iconRight != null)
          Padding(
            padding: EdgeInsets.only(left: iconSpace ?? 5).r,
            child: iconRight!,
          ),
      ],
    );
  }
}
