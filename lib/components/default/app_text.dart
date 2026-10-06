// Project imports:
import '../../imports.dart';

class AppText extends StatelessWidget {
  final String data;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool underline;
  final int? maxLines;
  final TextAlign? textAlign;
  final FontStyle? fontStyle;
  final bool isOverflow;
  final double? height;
  final bool isRequired;
  final TextOverflow? textOverflow;
  final TextStyle? textStyle;
  final TextDecoration? decoration;

  const AppText(
    this.data, {
    this.color,
    this.fontSize,
    this.fontWeight,
    this.underline = false,
    this.maxLines,
    this.textAlign,
    this.fontStyle,
    this.isOverflow = false,
    this.height,
    this.isRequired = false,
    this.textOverflow,
    this.textStyle,
    this.decoration,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return !isRequired
        ? textWidget(context)
        : Text.rich(
            TextSpan(
              children: [
                WidgetSpan(child: textWidget(context)),
                WidgetSpan(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5).r,
                    child: const AppText("*", color: Colors.red),
                  ),
                ),
              ],
            ),
          );
  }

  Widget textWidget(BuildContext context) {
    TextStyle textModeTextStyle = TextStyle(
      color: context.color.onSurface,
      fontSize: kFont13.sp,
      fontWeight: FontWeight.normal,
    );

    return DecoratedBox(
      decoration: const BoxDecoration(),
      // decoration: BoxDecoration(
      //   border: Border(
      //     bottom: underline
      //         ? BorderSide(
      //             color: color ?? textModeTextStyle.color!,
      //           )
      //         : BorderSide.none,
      //   ),
      // ),
      child: Text(
        data,
        maxLines: maxLines,
        overflow: !isOverflow ? null : textOverflow ?? TextOverflow.ellipsis,
        textAlign: textAlign,
        style:
            textStyle ??
            textModeTextStyle.copyWith(
              color: underline
                  ? AppColors.transparentColor
                  : color ?? textModeTextStyle.color,
              fontSize: fontSize?.sp ?? textModeTextStyle.fontSize,
              fontWeight: fontWeight ?? textModeTextStyle.fontWeight,
              fontStyle: fontStyle ?? FontStyle.normal,
              height: height,
              decoration: decoration ?? (underline ? TextDecoration.underline : null),
              decorationColor:
                  color ?? textModeTextStyle.color ?? AppColors.blackColor,
              shadows: underline
                  ? [
                      Shadow(
                        color:
                            color ??
                            textModeTextStyle.color ??
                            AppColors.blackColor,
                        offset: const Offset(0, -4),
                      ),
                    ]
                  : null,
            ),
      ),
    );
  }
}
