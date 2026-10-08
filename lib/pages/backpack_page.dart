// Project imports:
import '../imports.dart';
import 'login_page.dart';

/// The 背包 tab.
class BackpackPage extends StatelessWidget {
  const BackpackPage({super.key});

  @override
  Widget build(BuildContext context) {
    // logged out: the backpack tab is the login page, like the profile tab
    if (context.watch<AppController>().user == null) {
      return const LoginPage(isTab: true);
    }

    return AppScaffold.basic(
      backgroundColor: AppColors.whiteColor,
      forceOverlayStyle: SystemUiOverlayStyle.dark,
      child: SafeArea(
        child: Center(
          child: AppText(
            context.tr(AppStrings.backpack),
            fontSize: kFont18,
            fontWeight: FontWeight.w600,
            color: AppColors.blackColor,
          ),
        ),
      ),
    );
  }
}
