// Project imports:
import '../../imports.dart';

class DialogTextFormFieldWidget extends StatelessWidget {
  final String? routeName;
  final String? title;
  final String? message;
  final Widget? iconImage;
  final String? primaryButtonText;
  final Function()? onPrimaryTap;
  final Function()? onCloseTap;
  final bool? hasCloseTap;
  final Widget? icons;
  final Color? iconsColor;
  final bool? hasCancel;
  final bool? hasTopCancel;
  final TextEditingController? controller;
  final TextInputType? inputType;
  final int? maxLenght;

  const DialogTextFormFieldWidget({
    super.key,
    this.title,
    this.routeName,
    this.message,
    this.iconImage,
    this.primaryButtonText,
    this.onPrimaryTap,
    this.onCloseTap,
    this.icons,
    this.iconsColor,
    this.hasCloseTap = true,
    this.hasCancel = false,
    this.hasTopCancel = true,
    this.controller,
    this.inputType = TextInputType.text,
    this.maxLenght,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(kHorizontalPadding),
      child: Center(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(kHorizontalPadding.r),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: kHorizontalPadding),
                      AppText(
                        // context.tr(AppStrings.successful),
                        title ?? "",
                        fontWeight: FontWeight.bold,
                        color: context.color.secondary,
                      ),
                      5.h.heightSpace,
                      AppText(
                        // context.tr(AppStrings.successful),
                        message ?? "",
                        // fontWeight: FontWeight.bold,
                      ),
                      kHorizontalPadding.heightSpace,
                      AppTextFormField(
                        maxLength: maxLenght,
                        focusNode: FocusNode(),
                        controller: controller,
                        textInputType: inputType!,
                      ),
                      (kHorizontalPadding).heightSpace,
                      // if(onPrimaryTap != null )
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            if (hasCancel!)
                              Expanded(
                                flex: 1,
                                child: AppButtonWidget(
                                  buttonColor: AppColors.transparentColor,
                                  borderColor: context.color.secondary,
                                  textColor: context.color.secondary,
                                  borderStroke: 2,
                                  onTap: () {
                                    AppNavigator.pop(context);
                                    // AppNavigator.popUntilFirst(context);
                                    // AppNavigator.pushNamed(
                                    //     context, RouteName.appointmentPage);
                                  },
                                  text: context.tr(AppStrings.close),
                                ),
                              ),
                            (kHorizontalPadding / 2).widthSpace,
                            Expanded(
                              flex: 1,
                              child: AppButtonWidget(
                                borderStroke: 2,
                                onTap:
                                    onPrimaryTap ??
                                    () {
                                      if (routeName != null) {
                                        AppNavigator.popUntil(
                                          context,
                                          routeName!,
                                        );
                                      } else {
                                        AppNavigator.popUntilFirst(context);
                                      }

                                      // AppNavigator.pop(context);
                                      // AppNavigator.popUntilFirst(context);
                                      // AppNavigator.pushNamed(
                                      //     context, RouteName.appointmentPage);
                                    },
                                text:
                                    primaryButtonText ??
                                    context.tr(AppStrings.view),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (hasTopCancel!)
              Positioned(
                top: 5,
                right: 5,
                child: InkWellWrapper(
                  onTap:
                      onCloseTap ??
                      () {
                        AppNavigator.pop(context);
                      },
                  child: const SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(
                      Iconsax.close_circle_copy,
                      color: AppColors.textLightColor,
                      size: 30,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
