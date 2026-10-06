// Project imports:
import 'package:getithk/models/user_model.dart';
import '../imports.dart';

class LoginController extends ChangeNotifier {
  BuildContext context = NavigationService.context;
  bool _isDisposed = false;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> onLogin() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    FocusManager.instance.primaryFocus?.unfocus();

    Loader.show();
    await 1.delay();
    Loader.hide();

    final String email = emailController.text.trim();

    context.read<AppController>().setUser = UserModel(
      id: 1,
      name: email.split("@").first,
      email: email,
    );

    context.read<AppController>().navigateToTab(kBottomNavHome);
    AppNavigator.popUntilFirst(context);
    AppNavigator.pushReplacementNamed(context, RouteName.mainPage);
  }

  @override
  void dispose() {
    _isDisposed = true;
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void update() {
    if (!_isDisposed) notifyListeners();
  }
}
