// Dart imports:
import 'dart:math' as math;

// Package imports:
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

// Project imports:
import '../components/default/bottom_nav_bar_widget.dart';
import '../controllers/login_controller.dart';
import '../controllers/register_controller.dart';
import '../imports.dart';
import 'tnc_page.dart';

class LoginPage extends StatefulWidget {
  final bool isRegister;

  final bool isTab;

  const LoginPage({this.isRegister = false, this.isTab = false, super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const Duration _switchDuration = Duration(milliseconds: 250);

  late bool _isRegister = widget.isRegister;

  late final TapGestureRecognizer _termsRecognizer = TapGestureRecognizer()
    ..onTap = () => TncPage.open(context, TncType.terms);
  late final TapGestureRecognizer _privacyRecognizer = TapGestureRecognizer()
    ..onTap = () => TncPage.open(context, TncType.privacy);

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  void _fillTestAccount(BuildContext context) {
    final LoginController login = context.read<LoginController>();

    _setRegister(false);
    login.onSelectMethod(LoginMethod.email);
  }

  void _setRegister(bool value) {
    if (_isRegister == value) return;
    unfocusKeyboard();
    setState(() => _isRegister = value);
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
    final Color headerColor = context.color.primary;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginController()),
        ChangeNotifierProvider(create: (_) => RegisterController()),
      ],
      child: AppScaffold.basic(
        backgroundColor: AppColors.backgroundColor,
        forceOverlayStyle: SystemUiOverlayStyle.light,
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ColoredBox(
                color: headerColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [_header(), _sheet()],
                ),
              ),
            ),
            // keeps the status bar coloured once the sheet scrolls up
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.paddingOf(context).top,
              child: ColoredBox(color: headerColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20.r,
        MediaQuery.paddingOf(context).top + (widget.isTab ? 24.r : 8.r),
        20.r,
        36.r,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.isTab) ...[_backButton(), 24.heightSpace],
          // debug builds: a double tap fills in the test account
          Builder(
            builder: (context) => GestureDetector(
              onDoubleTap: kDebugMode ? () => _fillTestAccount(context) : null,
              child: AnimatedSwitcher(
                duration: _switchDuration,
                layoutBuilder: _topLeftLayout,
                child: Column(
                  key: ValueKey(_isRegister),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      context.tr(
                        _isRegister
                            ? AppStrings.registerTitle
                            : AppStrings.loginTitle,
                      ),
                      fontSize: kFont26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.whiteColor,
                    ),
                    6.heightSpace,
                    AppText(
                      context.tr(
                        _isRegister
                            ? AppStrings.registerSubtitle
                            : AppStrings.loginSubtitle,
                      ),
                      fontSize: kFont14,
                      color: AppColors.whiteColor.wOpacity(0.75),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _backButton() {
    return InkWellWrapper(
      onTap: _onBack,
      child: Container(
        width: 40.r,
        height: 40.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.whiteColor.wOpacity(0.15),
          border: Border.all(color: AppColors.whiteColor.wOpacity(0.2)),
        ),
        child: Icon(
          Iconsax.arrow_left_copy,
          size: 20.r,
          color: AppColors.whiteColor,
        ),
      ),
    );
  }

  Widget _sheet() {
    final double bottomInset = widget.isTab
        ? BottomNavigationWidget.contentBottomInset(context)
        : 16.r + MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20.r, 28.r, 20.r, bottomInset),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: AnimatedSize(
        duration: _switchDuration,
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: AnimatedSwitcher(
          duration: _switchDuration,
          layoutBuilder: _topLeftLayout,
          child: _isRegister
              ? Consumer<RegisterController>(
                  key: const ValueKey('register'),
                  builder: (context, controller, _) =>
                      _registerForm(controller),
                )
              : Consumer<LoginController>(
                  key: const ValueKey('login'),
                  builder: (context, controller, _) => _loginForm(controller),
                ),
        ),
      ),
    );
  }

  static Widget _topLeftLayout(Widget? current, List<Widget> previous) {
    return Stack(
      alignment: Alignment.topLeft,
      children: [...previous, ?current],
    );
  }

  Widget _methodSwitch({
    required bool isEmail,
    required ValueChanged<bool> onChanged,
  }) {
    final Color primary = context.color.primary;
    final List<(IconData, String)> options = [
      (Iconsax.sms, context.tr(AppStrings.email)),
      (Iconsax.call, context.tr(AppStrings.phoneNumber)),
    ];

    return Container(
      height: 48.r,
      decoration: BoxDecoration(
        color: AppColors.loginFieldColor,
        borderRadius: BorderRadius.circular(14).r,
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: isEmail ? Alignment.centerLeft : Alignment.centerRight,
            duration: _switchDuration,
            curve: Curves.easeOutCubic,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor,
                  borderRadius: BorderRadius.circular(14).r,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blackColor.wOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (int i = 0; i < options.length; i++)
                Expanded(
                  child: InkWellWrapper(
                    onTap: () => onChanged(i == 0),
                    child: Center(
                      child: _methodLabel(
                        options[i],
                        color: (i == 0) == isEmail
                            ? primary
                            : AppColors.loginHintColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _methodLabel((IconData, String) option, {required Color color}) {
    final (IconData icon, String text) = option;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18.r, color: color),
        6.widthSpace,
        Flexible(
          child: AppText(
            text,
            fontSize: kFont13,
            fontWeight: FontWeight.w600,
            color: color,
            isOverflow: true,
          ),
        ),
      ],
    );
  }

  Widget _submitButton(String text, VoidCallback onTap) {
    return AppButtonWidget(
      text: text,
      radius: 14,
      textSize: kFont15,
      textColor: AppColors.whiteColor,
      padding: const EdgeInsets.symmetric(vertical: 14).r,
      onTap: onTap,
    );
  }

  Widget _socialSection(void Function(SocialProvider provider) onSocial) {
    // Facebook and Apple hidden for now, on staging and live
    final List<SocialProvider> providers = [
      // SocialProvider.facebook,
      SocialProvider.google,
      // SocialProvider.apple,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        24.heightSpace,
        Row(
          children: [
            Expanded(child: Divider(color: AppColors.loginDividerColor)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12).r,
              child: AppText(
                context.tr(AppStrings.orContinueWith),
                fontSize: kFont12,
                color: AppColors.loginHintColor,
              ),
            ),
            Expanded(child: Divider(color: AppColors.loginDividerColor)),
          ],
        ),
        16.heightSpace,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < providers.length; i++) ...[
              if (i > 0) 12.widthSpace,
              _socialButton(providers[i], onTap: () => onSocial(providers[i])),
            ],
          ],
        ),
      ],
    );
  }

  Widget _socialButton(SocialProvider provider, {required VoidCallback onTap}) {
    final (String icon, Color? tint) = switch (provider) {
      SocialProvider.facebook => (
        AppAssets.icFacebook,
        AppColors.facebookColor,
      ),
      SocialProvider.google => (AppAssets.icGoogle, null),
      SocialProvider.apple => (AppAssets.icApple, AppColors.textColor),
    };

    // icon only, so the name is kept for screen readers
    return Semantics(
      label: provider.label,
      button: true,
      child: AppButtonWidget(
        buttonColor: AppColors.surfaceColor,
        borderColor: AppColors.loginDividerColor,
        radius: 14,
        padding: EdgeInsets.zero,
        width: 64.r,
        onTap: onTap,
        builder: SizedBox(
          height: 48.r,
          child: Center(
            child: AppImage(name: icon, width: 22.r, height: 22.r, color: tint),
          ),
        ),
      ),
    );
  }

  Widget _switchPrompt({
    required String question,
    required String action,
    required VoidCallback onTap,
  }) {
    return Center(
      child: InkWellWrapper(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8).r,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                question,
                fontSize: kFont13,
                color: AppColors.loginHintColor,
              ),
              4.widthSpace,
              AppText(
                action,
                fontSize: kFont13,
                fontWeight: FontWeight.w700,
                color: context.color.primary,
              ),
            ],
          ),
        ),
      ),
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

  Widget _loginForm(LoginController controller) {
    final bool isEmail = controller.method == LoginMethod.email;

    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _methodSwitch(
            isEmail: isEmail,
            onChanged: (email) => controller.onSelectMethod(
              email ? LoginMethod.email : LoginMethod.phone,
            ),
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

          _submitButton(context.tr(AppStrings.login), controller.onLogin),
          _socialSection(controller.onSocialLogin),
          20.heightSpace,

          _switchPrompt(
            question: context.tr(AppStrings.noAccount),
            action: context.tr(AppStrings.register),
            onTap: () => _setRegister(true),
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
          _methodSwitch(
            isEmail: isEmail,
            onChanged: (email) => controller.onSelectType(
              email ? ContactType.email : ContactType.phone,
            ),
          ),
          20.heightSpace,

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

          _submitButton(context.tr(AppStrings.signUp), controller.onRegister),
          16.heightSpace,
          _registerAgreement(),
          _socialSection(controller.onSocialRegister),
          20.heightSpace,

          _switchPrompt(
            question: context.tr(AppStrings.haveAccount),
            action: context.tr(AppStrings.login),
            onTap: () => _setRegister(false),
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
