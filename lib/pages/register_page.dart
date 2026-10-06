import '../controllers/register_controller.dart';
import '../imports.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterController(),

      child: Consumer<RegisterController>(
        builder: (context, controller, _) {
          return AppScaffold.basic(
            backgroundColor: AppColors.darkBackgroundColor,
            forceOverlayStyle: SystemUiOverlayStyle.light,

            child: SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.fw,
                    vertical: 12.fh,
                  ),

                  child: Form(
                    key: controller.formKey,

                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        // Logo
                        AppImage(name: AppAssets.logo, height: 30.fh),

                        18.heightSpace,

                        // Title
                        AppText(
                          context.tr(AppStrings.createAccount),
                          fontSize: kFont20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.whiteColor,
                        ),

                        6.heightSpace,

                        // Description
                        AppText(
                          context.tr(
                            AppStrings
                                .pleaseFillInTheInformationBelowToCompleteRegistration,
                          ),
                          fontSize: kFont12,
                          color: AppColors.darkHintColor,
                        ),

                        20.heightSpace,

                        AppTextFormField(
                          controller: controller.usernameController,
                          validator: controller.usernameValidator,
                          reserveErrorSpace: true,
                          errorMaxLines: 1,
                          errorTextSize: kFont12,
                          labelText: context.tr(AppStrings.username),
                          textColor: AppColors.whiteColor,
                          horizontalPadding: 12.fw,
                          labelColor: AppColors.whiteColor,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 12,
                            ).r,
                            child: const Icon(
                              Icons.person,
                              size: 20,
                              color: Color(0xFF888888),
                            ),
                          ),

                          hintText: context.tr(AppStrings.enterUsername),
                          hintTextColor: const Color(0xFF888888),
                          borderColor: const Color.fromARGB(255, 59, 59, 59),
                          backgroundColor: const Color(0xFF1E1E1E),
                        ),

                        AppTextFormField(
                          controller: controller.phoneOrEmailController,
                          validator: controller.phoneOrEmailValidator,
                          reserveErrorSpace: true,
                          errorMaxLines: 1,
                          errorTextSize: kFont12,
                          labelText: context.tr(AppStrings.phoneNumberOrEmail),
                          textColor: AppColors.whiteColor,
                          labelColor: AppColors.whiteColor,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 12,
                            ).r,
                            child: const Icon(
                              Icons.email,
                              size: 20,
                              color: Color(0xFF888888),
                            ),
                          ),

                          hintText: context.tr(
                            AppStrings.enterPhoneNumberOrEmail,
                          ),
                          hintTextColor: const Color(0xFF888888),
                          borderColor: const Color.fromARGB(255, 59, 59, 59),
                          backgroundColor: const Color(0xFF1E1E1E),
                        ),

                        AppTextFormField(
                          controller: controller.passwordController,
                          validator: controller.passwordValidator,
                          reserveErrorSpace: true,
                          errorMaxLines: 1,
                          errorTextSize: kFont12,
                          obscureText: true,
                          obscureTextDisabledColor: const Color(0xFF606060),
                          labelText: context.tr(AppStrings.password),
                          labelColor: AppColors.whiteColor,
                          textColor: AppColors.whiteColor,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 12,
                            ).r,

                            child: const Icon(
                              Icons.lock,
                              size: 20,
                              color: Color(0xFF888888),
                            ),
                          ),

                          hintText: context.tr(AppStrings.enterPassword),
                          hintTextColor: const Color(0xFF888888),
                          borderColor: const Color.fromARGB(255, 59, 59, 59),
                          backgroundColor: const Color(0xFF1E1E1E),
                        ),

                        AppTextFormField(
                          controller: controller.confirmPasswordController,
                          validator: controller.confirmPasswordValidator,
                          reserveErrorSpace: true,
                          errorMaxLines: 1,
                          errorTextSize: kFont12,
                          obscureText: true,
                          obscureTextDisabledColor: const Color(0xFF606060),
                          labelText: context.tr(AppStrings.confirmPassword),
                          textColor: AppColors.whiteColor,
                          labelColor: AppColors.whiteColor,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 12,
                            ).r,
                            child: const Icon(
                              Icons.lock,
                              size: 20,
                              color: Color(0xFF888888),
                            ),
                          ),

                          hintText: context.tr(AppStrings.confirmPassword),
                          hintTextColor: const Color(0xFF888888),
                          borderColor: const Color.fromARGB(255, 59, 59, 59),
                          backgroundColor: const Color(0xFF1E1E1E),
                        ),

                        8.heightSpace,

                        AppButtonWidget(
                          text: context.tr(AppStrings.signUp),
                          gradient: AppColors.brandGradientColor,
                          radius: 14.r,
                          textSize: kFont15,
                          textColor: AppColors.whiteColor,

                          padding: const EdgeInsets.symmetric(vertical: 14).r,
                          onTap: () {
                            if (!(controller.formKey.currentState?.validate() ??
                                false)) {
                              return;
                            }
                            AppNavigator.pushNamed(context, RouteName.mainPage);
                          },
                        ),

                        24.heightSpace,

                        Row(
                          children: [
                            const Expanded(
                              child: Divider(
                                color: AppColors.darkDividerColor,
                                indent: 20,
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.fw),

                              child: AppText(
                                context.tr(AppStrings.orSignUpWith),
                                fontSize: kFont12,
                                color: AppColors.darkHintColor,
                                textAlign: TextAlign.center,
                              ),
                            ),

                            const Expanded(
                              child: Divider(
                                color: AppColors.darkDividerColor,
                                endIndent: 20,
                              ),
                            ),
                          ],
                        ),

                        24.heightSpace,

                        Center(
                          child: Wrap(
                            spacing: 20.fw,
                            runSpacing: 12.fh,
                            alignment: WrapAlignment.center,

                            children: [
                              _socialSignUpButton(
                                provider: 'Google',
                                icon: AppImage(
                                  name: AppAssets.googleIcon,
                                  width: 22.fw,
                                  height: 22.fw,
                                ),
                              ),

                              _socialSignUpButton(
                                provider: 'Apple',
                                icon: Icon(
                                  MdiIcons.apple,
                                  color: AppColors.whiteColor,
                                  size: 26.fw,
                                ),
                              ),

                              _socialSignUpButton(
                                provider: context.tr(AppStrings.wechat),
                                icon: Icon(
                                  MdiIcons.wechat,
                                  color: const Color(0xFF07C160),
                                  size: 30.fw,
                                ),
                              ),
                            ],
                          ),
                        ),

                        26.heightSpace,

                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 4.fw,

                            children: [
                              AppText(
                                context.tr(AppStrings.alreadyHaveAnAccount),
                                fontSize: kFont12,
                                color: AppColors.darkHintColor,
                              ),

                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () => AppNavigator.pushNamed(
                                  context,
                                  RouteName.loginPage,
                                ),

                                child: AppText(
                                  context.tr(AppStrings.loginNow),
                                  fontSize: kFont12,
                                  fontWeight: FontWeight.w600,
                                  color: context.color.primary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        8.heightSpace,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _socialSignUpButton({required String provider, required Widget icon}) {
    return SizedBox.square(
      dimension: 52.fw < 48 ? 48 : 52.fw,

      child: IconButton(
        tooltip: context.tr(AppStrings.signUpWithProvider, args: [provider]),

        style: IconButton.styleFrom(
          backgroundColor: AppColors.darkSurfaceColor,

          shape: const CircleBorder(
            side: BorderSide(color: AppColors.darkDividerColor),
          ),
        ),

        onPressed: () => ToastHelper.showToast(
          context.tr(AppStrings.socialSignUpUnavailable, args: [provider]),
        ),

        icon: icon,
      ),
    );
  }
}
