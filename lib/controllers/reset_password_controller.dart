// Project imports:
import '../imports.dart';

class ResetPasswordController extends ChangeNotifier {
  BuildContext context = NavigationService.context;
  bool _isDisposed = false;

  static const int minLength = 8;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String? currentPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return context.tr(AppStrings.passwordEmpty);
    }
    return null;
  }

  String? newPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return context.tr(AppStrings.newPasswordEmpty);
    }
    if (value.length < minLength) {
      return context.tr(AppStrings.passwordMinimumLength, args: ['$minLength']);
    }
    return null;
  }

  String? confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return context.tr(AppStrings.confirmNewPasswordEmpty);
    }
    if (value != newPasswordController.text) {
      return context.tr(AppStrings.confirmPasswordIsNotSameAsNewPassword);
    }
    return null;
  }

  Future<void> onSubmit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(formKey.currentState?.validate() ?? false)) return;

    await ApiService.api.resetPassword(
      currentPassword: currentPasswordController.text,
      password: newPasswordController.text,
      showLoader: true,
      onSuccess: (response) {
        response.showMessage();
        if (!_isDisposed) AppNavigator.pop(context);
      },
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
