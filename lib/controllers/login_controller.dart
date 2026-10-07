// Project imports:
import 'package:getithk/models/user_model.dart';
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

  String? phoneValidator(dynamic value) {
    final String phone = (value ?? "").toString().replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    if (phone.isEmpty) {
      return context.tr(AppStrings.phoneNumberRequired);
    }

    if (phone.length < 8) {
      return context.tr(AppStrings.invalidMobileNumber);
    }

    return null;
  }

  Future<void> onLogin() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    FocusManager.instance.primaryFocus?.unfocus();

    Loader.show();
    await 1.delay();
    Loader.hide();

    final bool isEmail = method == LoginMethod.email;
    final String email = emailController.text.trim();
    final String phone = phoneController.text.trim();

    context.read<AppController>().setUser = UserModel(
      id: 1,
      name: isEmail ? email.split("@").first : phone,
      email: isEmail ? email : null,
      phoneNo: isEmail ? null : phone,
    );

    context.read<AppController>().navigateToTab(kBottomNavHome);
    AppNavigator.popUntilFirst(context);
    AppNavigator.pushReplacementNamed(context, RouteName.mainPage);
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
