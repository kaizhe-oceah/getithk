// Project imports:
import '../components/app_background.dart';
import '../components/default/bottom_nav_bar_widget.dart';
import '../components/default/pop_scope_close_confirmation.dart';
import '../controllers/main_controller.dart';
import '../imports.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    printLog("===== main page init =====");
  }

  @override
  Widget build(BuildContext context) {
    return PopScopeCloseConfirmation(
      child: Consumer2<AppController, MainController>(
        builder: (BuildContext context, _appController, _mainController, _) {
          final navItems = _mainController.navItems;
          final pages = navItems.map((e) => e.page).toList();
          final bool glassNav = BottomNavigationWidget.glassSupported;

          return Scaffold(
            backgroundColor: AppColors.darkBackgroundColor,
            resizeToAvoidBottomInset: false,
            bottomNavigationBar: glassNav
                ? null
                : const BottomNavigationWidget(),
            body: Stack(
              children: [
                const AppBackground(),
                Positioned.fill(
                  child: PageView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: _mainController.pageController,
                    onPageChanged: _mainController.onPageChanged,
                    children: pages,
                  ),
                ),
                if (glassNav) const BottomNavigationWidget(),
              ],
            ),
          );
        },
      ),
    );
  }
}
