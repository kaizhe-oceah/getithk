// Project imports:
import '../../imports.dart';

class AppPinput extends StatelessWidget {
  final int length;
  final Color borderColor;
  final Color fillColor;
  final double pinSize;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Function(String)? onCompleted;
  final bool useNativeKeyboard;
  final double fontSize;
  final double radius;
  final bool autoFocus;
  final String? Function(String?)? validator;

  const AppPinput({
    super.key,
    this.length = 6,
    this.borderColor = AppColors.blackColor,
    this.fillColor = AppColors.whiteColor,
    this.pinSize = kToolbarHeight,
    this.controller,
    this.focusNode,
    this.onCompleted,
    this.useNativeKeyboard = true,
    this.fontSize = kFont13,
    this.radius = 8,
    this.autoFocus = true,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: (pinSize - 6).fw,
      height: (pinSize - 6).fw,
      textStyle: TextStyle(
        fontSize: fontSize.sp,
        color: AppColors.blackColor,
      ),
      decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(radius).r,
          border: Border.all(
            color: borderColor.wOpacity(0.25),
          )),
    );

    final focusedPinTheme = PinTheme(
      width: (pinSize - 6).fw,
      height: pinSize.fw,
      textStyle: TextStyle(
        fontSize: fontSize.sp,
        color: AppColors.blackColor,
      ),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(radius).r,
        border: Border.all(
          color: borderColor.wOpacity(1.0),
        ),
      ),
    );

    return SizedBox(
      height: pinSize.fw,
      child: Pinput(
        length: length,
        autofocus: autoFocus,
        controller: controller,
        focusNode: focusNode,
        onCompleted: onCompleted,
        useNativeKeyboard: useNativeKeyboard,
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: focusedPinTheme,
        validator: validator,
      ),
    );
  }
}
