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
  bool bottomNavTitleEnabled = true;

  double get _bottomSafeArea => ScreenUtil().bottomBarHeight * 0.5;

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

                // PageView for main navigation
                Positioned.fill(
                  left: 0,
                  top: 0,
                  right: 0,
                  bottom:
                      (bottomNavTitleEnabled
                          ? kBottomNavHeight
                          : kBottomNavigationBarHeight) +
                      _bottomSafeArea,
                  child: PageView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: _mainController.pageController,
                    onPageChanged: _mainController.onPageChanged,
                    children: pages,
                  ),
                ),

                // Bottom navigation bar
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  // Outer gradient = top border, fades out along the corners
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(1, 1, 1, 0),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0, 0.35],
                        colors: [
                          AppColors.bottomNavBorderColor,
                          AppColors.bottomNavBorderColor.wOpacity(0),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.blackColor.wOpacity(0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.bottomNavColor,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(23),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height:
                                (bottomNavTitleEnabled
                                    ? kBottomNavHeight
                                    : kBottomNavigationBarHeight) +
                                _bottomSafeArea,
                            child: Wrap(
                              children: <Widget>[
                                BottomNavigationWidget(
                                  titleEnabled: bottomNavTitleEnabled,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
