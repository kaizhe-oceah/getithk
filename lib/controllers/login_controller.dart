// Package imports:
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

// Project imports:
import '../imports.dart';

enum LoginMethod { email, phone }

class LoginController extends ChangeNotifier {
  BuildContext context = NavigationService.context;
  bool _isDisposed = false;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  /// The chosen login method; `null` shows the list of login options.
  LoginMethod? method;

  /// The phone field's starting country; one instance, as the field resets
  /// whenever it gets a new one.
  final PhoneNumber initialPhoneNumber = PhoneNumber(
    isoCode: kDefaultPhoneCountry,
    dialCode: kDefaultPhoneDialCode,
  );

  /// The phone field's number with its country, as typed.
  PhoneNumber? phoneNumber;

  void onPhoneChanged(PhoneNumber value) => phoneNumber = value;

  void onSelectMethod(LoginMethod value) {
    method = value;
    update();
  }

  void onBackToOptions() {
    FocusManager.instance.primaryFocus?.unfocus();
    method = null;
    passwordController.clear();
    update();
  }

  void onSocialLogin(String provider) {
    ToastHelper.showToast(
      context.tr(AppStrings.socialLoginUnavailable, args: [provider]),
    );
  }

  Future<void> onLogin() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    FocusManager.instance.primaryFocus?.unfocus();

    final bool isEmail = method == LoginMethod.email;

    await ApiService.api.login(
      showLoader: true,
      type: isEmail ? ContactType.email : ContactType.phone,
      email: isEmail ? emailController.text.trim() : null,
      phoneCode: isEmail ? null : phoneNumber?.dialCode,
      phoneNo: isEmail ? null : nationalPhoneNo(phoneNumber!),
      password: passwordController.text,
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
    super.dispose();
  }

  void update() {
    if (!_isDisposed) notifyListeners();
  }
}
