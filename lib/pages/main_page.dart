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

          return Scaffold(
            backgroundColor: AppColors.darkBackgroundColor,
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: [
                // Background
                const AppBackground(),

                // PageView for main navigation; runs under the floating nav
                // bar so the glass has something to show through. Scrollable
                // tab content should pad its bottom by
                // LiquidGlassNavBar.contentBottomInset.
                Positioned.fill(
                  child: PageView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: _mainController.pageController,
                    onPageChanged: _mainController.onPageChanged,
                    children: pages,
                  ),
                ),

                // Bottom navigation bar (positions itself)
                const BottomNavigationWidget(),
              ],
            ),
          );
        },
      ),
    );
  }
}
