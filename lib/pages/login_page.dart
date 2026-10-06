import 'package:getithk/controllers/login_controller.dart';
import '../imports.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginController(),

      child: Consumer<LoginController>(
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
                        AppText(
                          context.tr(AppStrings.welcomeBack),
                          fontSize: kFont20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.whiteColor,
                        ),

                        6.heightSpace,

                        AppText(
                          context.tr(AppStrings.loginDescription),
                          fontSize: kFont12,
                          color: AppColors.darkHintColor,
                        ),

                        30.heightSpace,

                        AppTextFormField(
                          controller: controller.emailController,
                          validator: StringValidator.emailValidator,
                          textInputType: TextInputType.emailAddress,
                          labelText: context.tr(AppStrings.loginIdentifier),
                          textColor: AppColors.whiteColor,
                          labelColor: AppColors.whiteColor,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 12,
                            ).r,
                            child: const Icon(
                              Icons.person_outline,
                              size: 20,
                              color: Color(0xFF888888),
                            ),
                          ),

                          hintText: context.tr(AppStrings.enterLoginIdentifier),
                          hintTextColor: const Color(0xFF888888),
                          borderColor: const Color.fromARGB(255, 59, 59, 59),
                          backgroundColor: const Color(0xFF1E1E1E),
                        ),

                        20.heightSpace,

                        AppTextFormField(
                          controller: controller.passwordController,
                          validator: StringValidator.passwordValidator,
                          obscureText: true,
                          obscureTextDisabledColor: const Color(0xFF606060),
                          labelText: context.tr(AppStrings.password),
                          labelSuffixChild: TextButton(
                            onPressed: () => ToastHelper.showToast(
                              context.tr(AppStrings.passwordResetUnavailable),
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: AppText(
                              context.tr(AppStrings.forgotPassword),
                              fontSize: kFont12,
                              color: AppColors.darkHintColor,
                            ),
                          ),
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

                        36.heightSpace,

                        AppButtonWidget(
                          text: context.tr(AppStrings.login),
                          gradient: AppColors.brandGradientColor,
                          radius: 14.r,
                          textSize: kFont15,
                          textColor: AppColors.whiteColor,

                          padding: const EdgeInsets.symmetric(vertical: 14).r,
                          onTap: controller.onLogin,
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
                                context.tr(AppStrings.orLoginWith),
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
                              _socialLoginButton(
                                provider: 'Google',
                                icon: AppImage(
                                  name: AppAssets.googleIcon,
                                  width: 22.fw,
                                  height: 22.fw,
                                ),
                              ),

                              _socialLoginButton(
                                provider: 'Apple',
                                icon: Icon(
                                  MdiIcons.apple,
                                  color: AppColors.whiteColor,
                                  size: 26.fw,
                                ),
                              ),

                              _socialLoginButton(
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
                                context.tr(AppStrings.dontHaveAnAccount),
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
                                  RouteName.registerPage,
                                ),

                                child: AppText(
                                  context.tr(AppStrings.registerNow),
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

  Widget _socialLoginButton({required String provider, required Widget icon}) {
    return SizedBox.square(
      dimension: 52.fw < 48 ? 48 : 52.fw,

      child: IconButton(
        tooltip: context.tr(AppStrings.loginWithProvider, args: [provider]),

        style: IconButton.styleFrom(
          backgroundColor: AppColors.darkSurfaceColor,

          shape: const CircleBorder(
            side: BorderSide(color: AppColors.darkDividerColor),
          ),
        ),

        onPressed: () => ToastHelper.showToast(
          context.tr(AppStrings.socialLoginUnavailable, args: [provider]),
        ),

        icon: icon,
      ),
    );
  }
}
