// Dart imports:
import 'dart:math' as math;

// Project imports:
import '../controllers/reset_password_controller.dart';
import '../imports.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ResetPasswordController(),
      child: AppScaffold.basic(
        backgroundColor: AppColors.whiteColor,
        forceOverlayStyle: SystemUiOverlayStyle.dark,
        headerWidgets: [
          AppBarWidget(
            text: context.tr(AppStrings.resetPassword),
            centerTitle: true,
            backgroundColor: AppColors.whiteColor,
            leading: const AppBarBackButton(),
          ),
        ],
        child: Consumer<ResetPasswordController>(
          builder: (context, controller, _) => _content(context, controller),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, ResetPasswordController controller) {
    return UnfocusWrapper(
      child: Form(
        key: controller.formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            kHorizontalPadding.r,
            16.r,
            kHorizontalPadding.r,
            20.r + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            _passwordField(
              controller: controller.currentPasswordController,
              validator: controller.currentPasswordValidator,
              labelText: context.tr(AppStrings.currentPassword),
              hintText: context.tr(AppStrings.enterCurrentPassword),
            ),
            _passwordField(
              controller: controller.newPasswordController,
              validator: controller.newPasswordValidator,
              labelText: context.tr(AppStrings.newPassword),
              hintText: context.tr(
                AppStrings.enterNewPassword,
                args: ['${ResetPasswordController.minLength}'],
              ),
            ),
            _passwordField(
              controller: controller.confirmPasswordController,
              validator: controller.confirmPasswordValidator,
              labelText: context.tr(AppStrings.confirmNewPassword),
              hintText: context.tr(AppStrings.reEnterNewPassword),
              textInputAction: TextInputAction.done,
              onEditingComplete: controller.onSubmit,
            ),
            8.heightSpace,
            AppButtonWidget(
              text: context.tr(AppStrings.confirm),
              radius: 10,
              textSize: kFont14,
              fontWeight: FontWeight.w600,
              textColor: AppColors.whiteColor,
              padding: const EdgeInsets.symmetric(vertical: 13).r,
              onTap: controller.onSubmit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String? Function(String?) validator,
    required String labelText,
    required String hintText,
    TextInputAction textInputAction = TextInputAction.next,
    VoidCallback? onEditingComplete,
  }) {
    return AppTextFormField(
      controller: controller,
      validator: validator,
      obscureText: true,
      obscureTextDisabledColor: AppColors.loginHintColor,
      reserveErrorSpace: true,
      errorMaxLines: 1,
      errorTextSize: kFont12,
      radius: 12,
      labelText: labelText,
      labelFontWeight: FontWeight.w500,
      labelColor: AppColors.loginTextColor,
      textColor: AppColors.loginTextColor,
      hintText: hintText,
      hintTextColor: AppColors.loginHintColor,
      borderColor: AppColors.greyLightColor,
      prefixIcon: SizedBox(
        height: math.max(kMinInteractiveDimension, 48.r),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12).r,
          child: Icon(
            Iconsax.lock_copy,
            size: 14.r,
            color: AppColors.loginHintColor,
          ),
        ),
      ),
      textInputAction: textInputAction,
      onEditingComplete: onEditingComplete,
    );
  }
}
