import 'package:getithk/imports.dart';

class RegisterController extends ChangeNotifier {
  BuildContext context = NavigationService.context;
  bool _isDisposed = false;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController referralCodeController = TextEditingController();

  /// The chosen sign-up method; `null` shows the list of options.
  ContactType? type;

  /// Wait between OTP sends.
  static const int _otpCooldownSeconds = 120;

  /// Seconds left before another OTP can be sent; 0 when it can.
  final ValueNotifier<int> otpCooldown = ValueNotifier(0);
  Timer? _otpTimer;

  /// Whether an OTP has been sent, so the button reads "Resend".
  bool otpSent = false;

  void onSelectType(ContactType value) {
    type = value;
    update();
  }

  void onBackToOptions() {
    FocusManager.instance.primaryFocus?.unfocus();
    type = null;
    passwordController.clear();
    confirmPasswordController.clear();
    otpController.clear();
    update();
  }

  void onSocialRegister(String provider) {
    ToastHelper.showToast(
      context.tr(AppStrings.socialLoginUnavailable, args: [provider]),
    );
  }

  String? passwordValidator(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return context.tr(AppStrings.passwordEmpty);
    }

    if (value.toString().length < 6) {
      return context.tr(AppStrings.passwordMinimumLength, args: ['6']);
    }

    return null;
  }

  String? confirmPasswordValidator(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return context.tr(AppStrings.confirmPasswordRequired);
    }

    if (value.toString() != passwordController.text) {
      return context.tr(AppStrings.passwordsDoNotMatch);
    }

    return null;
  }

  /// Whether [value] is a valid email / phone (whichever the form asks for),
  /// so an OTP can be sent to it.
  bool canSendOtpTo(String value) => type == ContactType.email
      ? AppRegex.registerEmail.hasMatch(value.trim())
      : StringValidator.phoneValidator(value) == null;

  /// Sends the OTP to the email / phone typed in the form.
  Future<void> onSendOtp() async {
    final ContactType? type = this.type;
    if (type == null) return;

    final bool isEmail = type == ContactType.email;
    final TextEditingController target = isEmail
        ? emailController
        : phoneController;
    if (otpCooldown.value > 0 || !canSendOtpTo(target.text)) return;

    FocusManager.instance.primaryFocus?.unfocus();

    await ApiService.api.sendOtp(
      showLoader: true,
      type: type,
      email: isEmail ? emailController.text.trim() : null,
      phoneCode: isEmail ? null : kDefaultPhoneCode,
      phoneNo: isEmail ? null : localPhoneNo(phoneController.text),
      onSuccess: (response) {
        response.showMessage();
        _startOtpCooldown();
      },
    );
  }

  void _startOtpCooldown() {
    otpSent = true;
    otpCooldown.value = _otpCooldownSeconds;

    _otpTimer?.cancel();
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      otpCooldown.value -= 1;
      if (otpCooldown.value <= 0) timer.cancel();
    });
  }

  Future<void> onRegister() async {
    final ContactType? type = this.type;
    if (type == null) return;

    // Check all TextFormField validators
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    final bool isEmail = type == ContactType.email;
    final String referralCode = referralCodeController.text.trim();

    await ApiService.api.register(
      showLoader: true,
      type: type,
      email: isEmail ? emailController.text.trim() : null,
      phoneCode: isEmail ? null : kDefaultPhoneCode,
      phoneNo: isEmail ? null : localPhoneNo(phoneController.text),
      authMethod: AuthMethod.password,
      password: passwordController.text,
      // the server asks for an OTP even on password sign-ups
      otp: otpController.text.trim(),
      referralCode: referralCode.isEmpty ? null : referralCode,
      onSuccess: (response) {
        response.showMessage();
        context.read<AppController>().signIn(response);
      },
    );
  }

  @override
  void dispose() {
    _isDisposed = true;

    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    otpController.dispose();
    referralCodeController.dispose();
    _otpTimer?.cancel();
    otpCooldown.dispose();

    super.dispose();
  }

  void update() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }
}
