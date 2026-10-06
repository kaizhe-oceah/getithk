// Project imports:
import '../../imports.dart';

class DialogSuccessFailureWidget extends StatelessWidget {
  final bool? isSuccess;
  final String? routeName;
  final String? title;
  final String? message;
  final Widget? iconImage;
  final String? primaryButtonText;
  final Function()? onPrimaryTap;
  final Function()? onCloseTap;
  final Widget? icons;
  final Color? iconsColor;
  final bool? hasCancel;

  const DialogSuccessFailureWidget({
    super.key,
    this.isSuccess = true,
    this.title,
    this.routeName,
    this.message,
    this.iconImage,
    this.primaryButtonText,
    this.onPrimaryTap,
    this.onCloseTap,
    this.icons,
    this.iconsColor,
    this.hasCancel = false,
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
                      Container(
                        padding: EdgeInsets.all(4.h),
                        decoration: BoxDecoration(
                          color:
                              iconsColor?.wOpacity(0.2) ??
                              (isSuccess!
                                  ? AppColors.successGreen.wOpacity(0.2)
                                  : AppColors.darkRedColor.wOpacity(0.2)),
                          borderRadius: BorderRadius.circular(100.h),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(6.h),
                          decoration: BoxDecoration(
                            color:
                                iconsColor?.wOpacity(0.7) ??
                                (isSuccess!
                                    ? AppColors.successGreen.wOpacity(0.7)
                                    : AppColors.darkRedColor.wOpacity(0.7)),
                            borderRadius: BorderRadius.circular(100.h),
                          ),
                          child:
                              icons ??
                              Icon(
                                isSuccess! ? Icons.check : Icons.close,
                                size: 40,
                                color: AppColors.whiteColor,
                              ),
                        ),
                      ),
                      const SizedBox(height: kHorizontalPadding),
                      AppText(
                        // context.tr(AppStrings.successful),
                        title ?? "",
                        fontWeight: FontWeight.bold,
                        color: context.color.primary,
                      ),
                      5.h.heightSpace,
                      AppText(
                        // context.tr(AppStrings.successful),
                        message ?? "",
                        // fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: kHorizontalPadding * 2),
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
            if (onCloseTap != null)
              Positioned(
                top: 5,
                right: 5,
                child: InkWellWrapper(
                  onTap:
                      onCloseTap ??
                      () {
                        AppNavigator.pop(context);
                      },
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(
                      MdiIcons.close,
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
