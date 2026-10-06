import 'package:getithk/imports.dart';
import 'package:getithk/models/user_model.dart';

class RegisterController extends ChangeNotifier {
  BuildContext context = NavigationService.context;
  bool _isDisposed = false;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneOrEmailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String? usernameValidator(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return context.tr(AppStrings.usernameRequired);
    }

    return null;
  }

  String? phoneOrEmailValidator(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return context.tr(AppStrings.phoneNumberOrEmailRequired);
    }

    final String input = value.toString().trim();

    // If user enters email
    if (input.contains("@")) {
      if (!AppRegex.email.hasMatch(input)) {
        return context.tr(AppStrings.emailInvalid);
      }
    } else {
      // If user enters phone number
      final String phone = input.replaceAll(RegExp(r'[^0-9]'), '');

      if (phone.length < 8) {
        return context.tr(AppStrings.invalidMobileNumber);
      }
    }

    return null;
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

  Future<void> onRegister() async {
    // Check all TextFormField validators
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    final String username = usernameController.text.trim();

    final String contact = phoneOrEmailController.text.trim();

    final String password = passwordController.text;

    final String confirmPassword = confirmPasswordController.text;

    String email = "";
    String phoneNo = "";
    String? countryCode;

    if (contact.contains("@")) {
      email = contact;
      phoneNo = "";
      countryCode = null;
    } else {
      email = "";

      String phone = contact.replaceAll(RegExp(r'[^0-9+]'), '');

      countryCode = "60";

      if (phone.startsWith("+60")) {
        phone = phone.substring(3);
      }
      // 60123456789 -> 123456789
      else if (phone.startsWith("60")) {
        phone = phone.substring(2);
      }
      // 0123456789 -> 123456789
      else if (phone.startsWith("0")) {
        phone = phone.substring(1);
      }

      phoneNo = phone;
    }

    await ApiService.api.register(
      showLoader: true,

      name: username,
      countryCode: countryCode,
      phoneNo: phoneNo,
      email: email,
      password: password,
      passwordConfirmation: confirmPassword,

      onSuccess: (response) async {
        response.showMessage();

        final data = response.data;

        if (data != null &&
            data is Map &&
            data["token"] != null &&
            data["user"] != null) {
          await ApiService.updateApiToken(data["token"].toString());

          context.read<AppController>().setUser = UserModel.fromJson(
            Map<String, dynamic>.from(data["user"]),
          );

          context.read<AppController>().navigateToTab(kBottomNavHome);

          AppNavigator.popUntilFirst(context);

          AppNavigator.pushReplacementNamed(context, RouteName.mainPage);

          return;
        }

        AppNavigator.pushReplacementNamed(context, RouteName.loginPage);
      },
    );
  }

  @override
  void dispose() {
    _isDisposed = true;

    usernameController.dispose();
    phoneOrEmailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  void update() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }
}
