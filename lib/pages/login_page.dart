// Project imports:
import '../controllers/login_controller.dart';
import '../controllers/register_controller.dart';
import '../imports.dart';

class LoginPage extends StatefulWidget {
  /// Opens on the 註冊 tab instead of 登入.
  final bool isRegister;

  const LoginPage({this.isRegister = false, super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 2,
    initialIndex: widget.isRegister ? 1 : 0,
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    _tabController.addListener(unfocusKeyboard);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onBack() {
    if (Navigator.of(context).canPop()) {
      AppNavigator.pop(context);
      return;
    }

    context.read<AppController>().navigateToTab(kBottomNavHome);
    AppNavigator.pushReplacementNamed(context, RouteName.mainPage);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginController()),
        ChangeNotifierProvider(create: (_) => RegisterController()),
      ],
      child: AppScaffold.basic(
        backgroundColor: AppColors.whiteColor,
        forceOverlayStyle: SystemUiOverlayStyle.dark,
        headerWidgets: [
          // back button only
          AppBarWidget(
            backgroundColor: AppColors.whiteColor,
            isDivider: false,
            leading: AppBarBackButton(onTap: _onBack),
          ),
        ],
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20).r,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(child: AppLogo(height: 36.r)),
                    kHorizontalPadding.heightSpace,
                    _tabs(),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _tabPage(
                      Consumer<LoginController>(
                        builder: (context, controller, _) =>
                            controller.method == null
                            ? _loginOptions(controller)
                            : _loginForm(controller),
                      ),
                    ),
                    _tabPage(_registerForm()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 登入 / 註冊 tabs; the underline and colours follow the swipe
  Widget _tabs() {
    final List<String> titles = [
      context.tr(AppStrings.login),
      context.tr(AppStrings.register),
    ];
    final Animation<double> animation = _tabController.animation!;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => Column(
        children: [
          Row(
            children: [
              for (int i = 0; i < titles.length; i++)
                _tab(
                  titles[i],
                  index: i,
                  selected: 1 - (animation.value - i).abs().clamp(0.0, 1.0),
                ),
            ],
          ),
          Align(
            alignment: Alignment(
              -1 + 2 * animation.value / (titles.length - 1),
              0,
            ),
            child: FractionallySizedBox(
              widthFactor: 1 / titles.length,
              child: Container(height: 2, color: context.color.primary),
            ),
          ),
          Container(height: 1, color: AppColors.loginDividerColor),
        ],
      ),
    );
  }

  /// [selected] goes from 0 to 1 as this tab swipes into view.
  Widget _tab(String title, {required int index, required double selected}) {
    return Expanded(
      child: InkWellWrapper(
        onTap: () => _tabController.animateTo(index),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.fh),
          child: AppText(
            title,
            fontSize: kFont16,
            fontWeight: FontWeight.w600,
            color: Color.lerp(
              AppColors.loginHintColor,
              context.color.primary,
              selected,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _tabPage(Widget child) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16).r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [kHorizontalPadding.heightSpace, child],
      ),
    );
  }

  Widget _loginOptions(LoginController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _optionButton(
          icon: Iconsax.sms_copy,
          text: context.tr(AppStrings.loginWithEmail),
          color: AppColors.loginFieldColor,
          contentColor: AppColors.loginTextColor,
          onTap: () => controller.onSelectMethod(LoginMethod.email),
        ),
        12.heightSpace,
        _optionButton(
          icon: Iconsax.call_copy,
          text: context.tr(AppStrings.loginWithPhone),
          color: AppColors.loginFieldColor,
          contentColor: AppColors.loginTextColor,
          onTap: () => controller.onSelectMethod(LoginMethod.phone),
        ),
        12.heightSpace,
        _optionButton(
          icon: Iconsax.facebook,
          text: context.tr(AppStrings.loginWithProvider, args: ['Facebook']),
          color: AppColors.facebookColor,
          onTap: () => controller.onSocialLogin('Facebook'),
        ),
        12.heightSpace,
        _optionButton(
          icon: Iconsax.google_1,
          text: context.tr(AppStrings.loginWithProvider, args: ['Google']),
          color: AppColors.googleColor,
          onTap: () => controller.onSocialLogin('Google'),
        ),
        12.heightSpace,
        _optionButton(
          icon: Iconsax.apple,
          text: context.tr(AppStrings.loginWithProvider, args: ['Apple']),
          color: AppColors.blackColor,
          onTap: () => controller.onSocialLogin('Apple'),
        ),
      ],
    );
  }

  Widget _optionButton({
    required IconData icon,
    required String text,
    required Color color,
    Color contentColor = AppColors.whiteColor,
    required VoidCallback onTap,
  }) {
    return AppButtonWidget(
      buttonColor: color,
      radius: 12,
      padding: EdgeInsets.zero,
      onTap: onTap,
      builder: SizedBox(
        height: 52.r,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 20.r,
              child: Icon(icon, size: 20.r, color: contentColor),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 48.r),
              child: AppText(
                text,
                fontSize: kFont14,
                fontWeight: FontWeight.w600,
                color: contentColor,
                textAlign: TextAlign.center,
                isOverflow: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loginForm(LoginController controller) {
    final bool isEmail = controller.method == LoginMethod.email;

    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              InkWellWrapper(
                onTap: controller.onBackToOptions,
                child: Padding(
                  padding: const EdgeInsets.all(4).r,
                  child: Icon(
                    Iconsax.arrow_left_copy,
                    size: 22.r,
                    color: AppColors.loginTextColor,
                  ),
                ),
              ),
              8.widthSpace,
              Expanded(
                child: AppText(
                  context.tr(
                    isEmail
                        ? AppStrings.loginWithEmail
                        : AppStrings.loginWithPhone,
                  ),
                  fontSize: kFont15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.loginTextColor,
                ),
              ),
            ],
          ),
          20.heightSpace,

          if (isEmail)
            _textField(
              key: const ValueKey('email'),
              controller: controller.emailController,
              validator: StringValidator.emailValidator,
              textInputType: TextInputType.emailAddress,
              labelText: context.tr(AppStrings.email),
              hintText: context.tr(AppStrings.enterEmail),
              icon: Iconsax.sms_copy,
            )
          else
            _textField(
              key: const ValueKey('phone'),
              controller: controller.phoneController,
              validator: controller.phoneValidator,
              textInputType: TextInputType.phone,
              labelText: context.tr(AppStrings.phoneNumber),
              hintText: context.tr(AppStrings.enterPhoneNumber),
              icon: Iconsax.call_copy,
            ),
          16.heightSpace,

          _textField(
            controller: controller.passwordController,
            validator: StringValidator.passwordValidator,
            obscureText: true,
            labelText: context.tr(AppStrings.password),
            hintText: context.tr(AppStrings.enterPassword),
            icon: Iconsax.lock_copy,
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
                color: AppColors.loginHintColor,
              ),
            ),
          ),
          24.heightSpace,

          AppButtonWidget(
            text: context.tr(AppStrings.login),
            radius: 12,
            textSize: kFont15,
            textColor: AppColors.whiteColor,
            padding: const EdgeInsets.symmetric(vertical: 15).r,
            onTap: controller.onLogin,
          ),
        ],
      ),
    );
  }

  // Sign-up form
  Widget _registerForm() {
    return Consumer<RegisterController>(
      builder: (context, controller, _) {
        return Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _textField(
                controller: controller.usernameController,
                validator: controller.usernameValidator,
                reserveErrorSpace: true,
                labelText: context.tr(AppStrings.username),
                hintText: context.tr(AppStrings.enterUsername),
                icon: Iconsax.user_copy,
              ),
              _textField(
                controller: controller.phoneOrEmailController,
                validator: controller.phoneOrEmailValidator,
                reserveErrorSpace: true,
                labelText: context.tr(AppStrings.phoneNumberOrEmail),
                hintText: context.tr(AppStrings.enterPhoneNumberOrEmail),
                icon: Iconsax.sms_copy,
              ),
              _textField(
                controller: controller.passwordController,
                validator: controller.passwordValidator,
                reserveErrorSpace: true,
                obscureText: true,
                labelText: context.tr(AppStrings.password),
                hintText: context.tr(AppStrings.enterPassword),
                icon: Iconsax.lock_copy,
              ),
              _textField(
                controller: controller.confirmPasswordController,
                validator: controller.confirmPasswordValidator,
                reserveErrorSpace: true,
                obscureText: true,
                labelText: context.tr(AppStrings.confirmPassword),
                hintText: context.tr(AppStrings.confirmPassword),
                icon: Iconsax.lock_copy,
              ),
              8.heightSpace,

              AppButtonWidget(
                text: context.tr(AppStrings.signUp),
                radius: 12,
                textSize: kFont15,
                textColor: AppColors.whiteColor,
                padding: const EdgeInsets.symmetric(vertical: 15).r,
                onTap: () {
                  if (!(controller.formKey.currentState?.validate() ?? false)) {
                    return;
                  }
                  AppNavigator.pushNamed(context, RouteName.mainPage);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// [AppTextFormField] styled for this page.
  Widget _textField({
    Key? key,
    required TextEditingController controller,
    required String? Function(String?) validator,
    required String labelText,
    required String hintText,
    required IconData icon,
    TextInputType textInputType = TextInputType.text,
    bool obscureText = false,
    bool reserveErrorSpace = false,
    Widget? labelSuffixChild,
  }) {
    return AppTextFormField(
      key: key,
      controller: controller,
      validator: validator,
      textInputType: textInputType,
      // null (not false) so non-password fields don't get the eye toggle
      obscureText: obscureText ? true : null,
      obscureTextDisabledColor: AppColors.loginHintColor,
      reserveErrorSpace: reserveErrorSpace,
      errorMaxLines: 1,
      errorTextSize: kFont12,
      radius: 12,
      labelText: labelText,
      labelSuffixChild: labelSuffixChild,
      labelColor: AppColors.loginTextColor,
      textColor: AppColors.loginTextColor,
      hintText: hintText,
      hintTextColor: AppColors.loginHintColor,
      backgroundColor: AppColors.loginFieldColor,
      borderColor: AppColors.loginFieldColor,
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 16, right: 12).r,
        child: Icon(icon, size: 18.r, color: AppColors.loginHintColor),
      ),
    );
  }
}
