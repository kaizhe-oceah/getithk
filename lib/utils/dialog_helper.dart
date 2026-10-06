// Package imports:
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:permission_handler/permission_handler.dart';

// Project imports:
import 'package:getithk/components/default/dialog_success_failure.dart';
import '../components/default/normal_dialog.dart';
import '../imports.dart';

class DialogHelper<T> {
  static BuildContext context = NavigationService.context;

  Future<T?> showOpenAppSettingDialog({
    String? title,
    required String description,
  }) async {
    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (_) => kIsWeb
          ? NormalDialog(
              title: title ?? context.tr(AppStrings.permissionDenied),
              description: description,
              rightButtonText: context.tr(AppStrings.okay),
              rightFunction: () {
                AppNavigator.pop(context);
              },
            )
          : NormalDialog(
              title: title ?? context.tr(AppStrings.permissionDenied),
              description: description,
              leftButtonText: context.tr(AppStrings.cancel),
              rightButtonText: context.tr(AppStrings.openSettings),
              leftFunction: () {
                AppNavigator.pop(context);
              },
              rightFunction: () {
                openAppSettings();
              },
            ),
    );
  }

  Future<T?> showDefaultDialog({
    required Widget child,
    BuildContext? context2,
    bool barrierDismissible = true,
  }) async {
    return showDialog<T>(
      context: context2 ?? context,
      barrierDismissible: barrierDismissible,
      builder: (_) => child,
    );
  }

  Future<T?> showNormalDialog({
    required String title,
    String? description,

    // Optional image displayed above title
    String? image,

    // Left button
    Function()? leftFunction,
    String? leftButtonText,
    Color? leftTextColor,
    Color? leftButtonColor,

    // Right button
    Function()? rightFunction,
    String? rightButtonText,
    Color? rightTextColor,
    Color? rightButtonColor,

    // Dismiss behavior
    bool barrierDismissible = true,

    // Custom content builder (optional)
    Widget? builder,
  }) async {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => NormalDialog(
        title: title,
        description: description,
        image: image, // new image param
        // Left button
        leftButtonText: leftButtonText,
        leftFunction: leftFunction,
        leftTextColor: leftTextColor,
        leftButtonColor: leftButtonColor,

        // Right button
        rightButtonText: rightButtonText ?? context.tr(AppStrings.okay),
        rightFunction: rightFunction ?? () => AppNavigator.pop(context),
        rightTextColor: rightTextColor,
        rightButtonColor: rightButtonColor,

        // Custom content
        builder: builder,
      ),
    );
  }

  Future<T?> showScrollableDialog({
    required Widget child,
    BuildContext? context2,
    bool barrierDismissible = true,
    heightPercent = 0.7,
  }) async {
    return showDialog<T>(
      context: context2 ?? context,
      barrierDismissible: barrierDismissible,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.all(kHorizontalPadding).r,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * heightPercent,
              ),
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(child: child),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<T?> appDialog({
    required String title,
    String? description,
    String? image,
    bool barrierDismissible = true,

    // Left button
    Function()? leftFunction,
    String? leftButtonText,
    Color? leftTextColor,
    Color? leftButtonColor,
    Color? leftButtonBorderColor,

    // Right button
    Function()? rightFunction,
    String? rightButtonText,
    Color? rightTextColor,
    Color? rightButtonColor,
    Color? rightButtonBorderColor,
  }) async {
    final hasButtons = leftButtonText != null || rightButtonText != null;

    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => NormalDialog(
        title: title,
        image: image,
        builder: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (description != null)
              AppText(description, textAlign: TextAlign.center),
            hasButtons ? 10.heightSpace : 20.heightSpace,
            if (hasButtons)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: kHorizontalPadding,
                ).r,
                child: Row(
                  children: [
                    if (leftButtonText != null)
                      Expanded(
                        child: AppButtonWidget(
                          text: leftButtonText,
                          buttonColor: leftButtonColor,
                          textColor: leftTextColor,
                          borderColor: leftButtonBorderColor,
                          onTap: leftFunction,
                        ),
                      ),
                    if (leftButtonText != null && rightButtonText != null)
                      10.widthSpace,
                    if (rightButtonText != null)
                      Expanded(
                        child: AppButtonWidget(
                          text: rightButtonText,
                          buttonColor: rightButtonColor,
                          textColor: rightTextColor,
                          borderColor: rightButtonBorderColor,
                          onTap: rightFunction,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<T?> showHtmlDialog({
    required String htmlContent,
    String? title,
  }) async {
    return showDialog<T>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10).r,
        ),
        backgroundColor: AppColors.whiteColor,
        title: title != null
            ? AppText(title, fontWeight: FontWeight.w600)
            : null,
        content: SingleChildScrollView(
          child: HtmlWidget(
            htmlContent,
            onLoadingBuilder: (context, element, loadingProgress) {
              return Loader.loaderWidget();
            },
          ),
        ),
        actions: [
          AppButtonWidget(
            onTap: () => AppNavigator.pop(context),
            text: context.tr(AppStrings.close),
          ),
        ],
      ),
    );
  }

  void dialogSuccessPayment({
    required BuildContext context,
    String? title,
    String? primaryButtonText,
    String? message,
    bool isSuccess = true,
    Function()? onCloseTap,
    Function()? onPrimaryTap,
  }) {
    DialogHelper().showDefaultDialog(
      barrierDismissible: false,
      child: DialogSuccessFailureWidget(
        primaryButtonText: primaryButtonText ?? context.tr(AppStrings.okay),
        title: title ?? context.tr(AppStrings.paymentSuccessful),
        message: message,
        isSuccess: isSuccess,
        onCloseTap: onCloseTap,
        onPrimaryTap: onPrimaryTap,
      ),
    );
  }
}
