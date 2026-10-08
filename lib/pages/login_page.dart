// Dart imports:
import 'dart:math' as math;

// Package imports:
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:liquid_glass_bottom_nav/liquid_glass_bottom_nav.dart';

// Project imports:
import '../controllers/login_controller.dart';
import '../controllers/register_controller.dart';
import '../imports.dart';

class LoginPage extends StatefulWidget {
  final bool isRegister;

  final bool isTab;

  const LoginPage({this.isRegister = false, this.isTab = false, super.key});

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

  late final TapGestureRecognizer _termsRecognizer = TapGestureRecognizer()
    ..onTap = () => _openTnc(TncType.terms);
  late final TapGestureRecognizer _privacyRecognizer = TapGestureRecognizer()
    ..onTap = () => _openTnc(TncType.privacy);

  @override
  void initState() {
    super.initState();
    _tabController.addListener(unfocusKeyboard);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  static const String _testEmail = 'lamkaizhe2001@gmail.com';
  static const String _testPassword = '123123123';

  /// Debug builds only (the logo's double tap): the login tab's email form,
  /// filled in with the test account.
  void _fillTestAccount(BuildContext context) {
    final LoginController login = context.read<LoginController>();

    _tabController.animateTo(0);
    login.onSelectMethod(LoginMethod.email);
    login.emailController.text = _testEmail;
    login.passwordController.text = _testPassword;
  }

  void _openTnc(TncType type) =>
      AppNavigator.pushNamed(context, RouteName.tncPage, arguments: type);

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
          // back button, logo centred
          AppBarWidget(
            backgroundColor: AppColors.whiteColor,
            isDivider: false,
            leading: widget.isTab ? null : AppBarBackButton(onTap: _onBack),
            // debug builds: a double tap fills in the test account
            title: Builder(
              builder: (context) => GestureDetector(
                onDoubleTap: kDebugMode ? () => _fillTestAccount(context) : null,
                child: AppLogo(height: 32.r),
              ),
            ),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20).r,
              child: _tabs(),
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
                  _tabPage(
                    Consumer<RegisterController>(
                      builder: (context, controller, _) =>
                          controller.type == null
                          ? _registerOptions(controller)
                          : _registerForm(controller),
                    ),
                    footer: _registerAgreement(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _tab(String title, {required int index, required double selected}) {
    return Expanded(
      child: InkWellWrapper(
        onTap: () => _tabController.animateTo(index),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.fh),
          child: AppText(
            title,
            fontSize: kFont15,
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

  Widget _tabPage(Widget child, {Widget? footer}) {
    final double navBarInset = widget.isTab
        ? LiquidGlassNavBar.contentBottomInset +
              MediaQuery.paddingOf(context).bottom
        : 16.r;

    final Widget scrollView = SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20.r,
        0,
        20.r,
        footer == null ? navBarInset : 16.r,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [kHorizontalPadding.heightSpace, child],
      ),
    );
    if (footer == null) return scrollView;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: scrollView),
        if (!KeyboardVisibilityProvider.isKeyboardVisible(context))
          Padding(
            padding: EdgeInsets.fromLTRB(
              20.r,
              0,
              20.r,
              widget.isTab
                  ? navBarInset
                  : navBarInset + MediaQuery.paddingOf(context).bottom,
            ),
            child: footer,
          ),
      ],
    );
  }

  Widget _registerAgreement() {
    final Color primary = context.color.primary;
    final TextStyle style = TextStyle(
      fontSize: kFont12.sp,
      color: AppColors.loginHintColor,
    );
    final TextStyle linkStyle = style.copyWith(
      color: primary,
      decoration: TextDecoration.underline,
      decorationColor: primary,
    );
    final List<TextSpan> links = [
      TextSpan(
        text: context.tr(AppStrings.termsOfService),
        style: linkStyle,
        recognizer: _termsRecognizer,
      ),
      TextSpan(
        text: context.tr(AppStrings.privacyPolicy),
        style: linkStyle,
        recognizer: _privacyRecognizer,
      ),
    ];

    final List<String> parts = context
        .tr(AppStrings.registerAgreement)
        .split('{}');

    return Text.rich(
      TextSpan(
        style: style,
        children: [
          for (int i = 0; i < parts.length; i++) ...[
            TextSpan(text: parts[i]),
            if (i < parts.length - 1 && i < links.length) links[i],
          ],
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _loginOptions(LoginController controller) {
    return _methodOptions(
      emailText: context.tr(AppStrings.loginWithEmail),
      phoneText: context.tr(AppStrings.loginWithPhone),
      providerTextKey: AppStrings.loginWithProvider,
      onEmail: () => controller.onSelectMethod(LoginMethod.email),
      onPhone: () => controller.onSelectMethod(LoginMethod.phone),
      onSocial: controller.onSocialLogin,
    );
  }

  Widget _registerOptions(RegisterController controller) {
    return _methodOptions(
      emailText: context.tr(AppStrings.registerWithEmail),
      phoneText: context.tr(AppStrings.registerWithPhone),
      providerTextKey: AppStrings.registerWithProvider,
      onEmail: () => controller.onSelectType(ContactType.email),
      onPhone: () => controller.onSelectType(ContactType.phone),
      onSocial: controller.onSocialRegister,
    );
  }

  Widget _methodOptions({
    required String emailText,
    required String phoneText,
    required String providerTextKey,
    required VoidCallback onEmail,
    required VoidCallback onPhone,
    required void Function(String provider) onSocial,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _optionButton(
          icon: Iconsax.sms,
          text: emailText,
          color: AppColors.loginFieldColor,
          contentColor: AppColors.loginTextColor,
          onTap: onEmail,
        ),
        12.heightSpace,
        _optionButton(
          icon:Iconsax.call,
          text: phoneText,
          color: AppColors.loginFieldColor,
          contentColor: AppColors.loginTextColor,
          onTap: onPhone,
        ),
        12.heightSpace,
        _optionButton(
          icon: Iconsax.facebook,
          text: context.tr(providerTextKey, args: ['Facebook']),
          color: AppColors.facebookColor,
          onTap: () => onSocial('Facebook'),
        ),
        12.heightSpace,
        _optionButton(
          icon: Iconsax.google_1,
          text: context.tr(providerTextKey, args: ['Google']),
          color: AppColors.googleColor,
          onTap: () => onSocial('Google'),
        ),
        12.heightSpace,
        _optionButton(
          icon: Iconsax.apple,
          text: context.tr(providerTextKey, args: ['Apple']),
          color: AppColors.blackColor,
          onTap: () => onSocial('Apple'),
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
      radius: 15.r,
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

  /// ← 返回選擇方式, back to the list of login / sign-up options (the whole
  /// line is tappable).
  Widget _formHeader({required VoidCallback onBack}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWellWrapper(
        onTap: onBack,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 8, 4).r,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Iconsax.arrow_left_copy,
                size: 20.r,
                color: AppColors.loginTextColor,
              ),
              8.widthSpace,
              AppText(
                context.tr(AppStrings.backToOptions),
                fontSize: kFont13,
                fontWeight: FontWeight.w500,
                color: AppColors.loginTextColor,
              ),
            ],
          ),
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
          _formHeader(onBack: controller.onBackToOptions),
          10.heightSpace,

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
            _phoneField(
              key: const ValueKey('phone'),
              controller: controller.phoneController,
              initialPhoneNumber: controller.initialPhoneNumber,
              onChanged: controller.onPhoneChanged,
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

  Widget _registerForm(RegisterController controller) {
    final bool isEmail = controller.type == ContactType.email;

    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _formHeader(onBack: controller.onBackToOptions),
          10.heightSpace,

          if (isEmail)
            _textField(
              key: const ValueKey('register_email'),
              controller: controller.emailController,
              validator: StringValidator.registerEmailValidator,
              textInputType: TextInputType.emailAddress,
              reserveErrorSpace: true,
              labelText: context.tr(AppStrings.email),
              hintText: context.tr(AppStrings.enterEmail),
              icon: Iconsax.sms,
            )
          else
            _phoneField(
              key: const ValueKey('register_phone'),
              controller: controller.phoneController,
              initialPhoneNumber: controller.initialPhoneNumber,
              onChanged: controller.onPhoneChanged,
              onChecking: controller.onPhoneChecking,
              reserveErrorSpace: true,
            ),
          _textField(
            controller: controller.passwordController,
            validator: controller.passwordValidator,
            reserveErrorSpace: true,
            obscureText: true,
            labelText: context.tr(AppStrings.password),
            hintText: context.tr(AppStrings.enterPassword),
            icon: Iconsax.lock,
          ),
          _textField(
            controller: controller.confirmPasswordController,
            validator: controller.confirmPasswordValidator,
            reserveErrorSpace: true,
            obscureText: true,
            labelText: context.tr(AppStrings.confirmPassword),
            hintText: context.tr(AppStrings.confirmPassword),
            icon: Iconsax.lock,
          ),
          _otpField(controller, isEmail: isEmail),
          _textField(
            controller: controller.referralCodeController,
            validator: (_) => null, // optional
            reserveErrorSpace: true,
            labelText: context.tr(AppStrings.referralCode),
            hintText: context.tr(AppStrings.enterReferralCode),
            icon: Iconsax.gift,
          ),
          8.heightSpace,

          AppButtonWidget(
            text: context.tr(AppStrings.signUp),
            radius: 12,
            textSize: kFont15,
            textColor: AppColors.whiteColor,
            padding: const EdgeInsets.symmetric(vertical: 12).r,
            onTap: controller.onRegister,
          ),
        ],
      ),
    );
  }

  Widget _textField({
    Key? key,
    required TextEditingController controller,
    required String? Function(String?) validator,
    String? labelText,
    required String hintText,
    required IconData icon,
    TextInputType textInputType = TextInputType.text,
    List<TextInputFormatter>? textInputFormatter,
    bool obscureText = false,
    bool reserveErrorSpace = false,
    Widget? labelSuffixChild,
  }) {
    return AppTextFormField(
      key: key,
      controller: controller,
      validator: validator,
      textInputType: textInputType,
      textInputFormatter: textInputFormatter,
      obscureText: obscureText ? true : null,
      obscureTextDisabledColor: AppColors.loginHintColor,
      reserveErrorSpace: reserveErrorSpace,
      errorMaxLines: 1,
      errorTextSize: kFont12,

      radius: 12,
      labelFontWeight: FontWeight.w500,
      labelText: labelText,
      labelSuffixChild: labelSuffixChild,
      labelColor: AppColors.loginTextColor,
      textColor: AppColors.loginTextColor,
      hintText: hintText,
      hintTextColor: AppColors.loginHintColor,
      borderColor: AppColors.greyLightColor,
      prefixIcon: SizedBox(
        height: _fieldHeight,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 12).r,
          child: Icon(icon, size: 18.r, color: AppColors.loginHintColor),
        ),
      ),
    );
  }

  double get _fieldHeight => math.max(kMinInteractiveDimension, 48.r);

  Widget _phoneField({
    Key? key,
    required TextEditingController controller,
    required PhoneNumber initialPhoneNumber,
    required ValueChanged<PhoneNumber> onChanged,
    ValueChanged<bool>? onChecking,
    bool reserveErrorSpace = false,
  }) {
    return AppPhoneFormField(
      key: key,
      controller: controller,
      initPhoneNumber: initialPhoneNumber,
      onChanged: onChanged,
      onChecking: onChecking ?? (_) {},
      height: _fieldHeight,
      radius: 12,
      reserveErrorSpace: reserveErrorSpace,
      errorMaxLines: 1,
      errorTextSize: kFont12,
      labelText: context.tr(AppStrings.phoneNumber),
      labelFontWeight: FontWeight.w500,
      labelColor: AppColors.loginTextColor,
      textColor: AppColors.loginTextColor,
      hintText: context.tr(AppStrings.enterPhoneNumber),
      hintTextColor: AppColors.loginHintColor,
      borderColor: AppColors.greyLightColor,
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5).r,
      child: AppText(
        text,
        fontWeight: FontWeight.w500,
        color: AppColors.loginTextColor,
        fontSize: kFont13,
      ),
    );
  }

  Widget _otpField(RegisterController controller, {required bool isEmail}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _fieldLabel(context.tr(AppStrings.otp)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _textField(
                controller: controller.otpController,
                validator: StringValidator.otpValidator,
                textInputType: TextInputType.number,
                // digits only, at most 6 (also blocks pasting anything else)
                textInputFormatter: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                reserveErrorSpace: true,
                hintText: context.tr(AppStrings.enterOtp),
                icon: Iconsax.shield_tick,
              ),
            ),
            5.widthSpace,
            SizedBox(
              height: _fieldHeight,
              child: _sendOtpButton(controller, isEmail: isEmail),
            ),
          ],
        ),
      ],
    );
  }

  /// "Send OTP" → grey countdown ("120s" … "1s") after a send → "Resend".
  /// Only tappable when the email / phone is valid and not cooling down.
  Widget _sendOtpButton(
    RegisterController controller, {
    required bool isEmail,
  }) {
    final TextEditingController target = isEmail
        ? controller.emailController
        : controller.phoneController;

    return ListenableBuilder(
      listenable: Listenable.merge([
        target,
        controller.otpCooldown,
        controller.phoneValid,
      ]),
      builder: (context, _) {
        final int seconds = controller.otpCooldown.value;
        final bool canSend =
            seconds == 0 && controller.canSendOtpTo(target.text);

        return ConstrainedBox(
          // fixed minimum so the OTP field doesn't shift as the label changes
          constraints: BoxConstraints(minWidth: 96.r),
          child: AppButtonWidget(
            text: seconds > 0
                ? "${seconds}s"
                : context.tr(
                    controller.otpSent
                        ? AppStrings.resendOtp
                        : AppStrings.sendOtp,
                  ),
            isMinWidth: true,
            radius: 12,
            textSize: kFont13,
            textColor: AppColors.whiteColor,
            padding: const EdgeInsets.symmetric(horizontal: 12).r,
            onTap: canSend ? controller.onSendOtp : null,
          ),
        );
      },
    );
  }
}
