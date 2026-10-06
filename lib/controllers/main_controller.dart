// Project imports:
import '../imports.dart';
import '../models/bottom_nav_model.dart';
import '../utils/app_nav_pages.dart';

class MainController extends ChangeNotifier {
  BuildContext context = NavigationService.context;
  bool _isDisposed = false;

  final pageController = PageController(initialPage: 0);
  int currentTab = 0;

  /// Returns correct navigation list based on role
  List<BottomNavModel> get navItems {
    final themeController = context.read<ThemeController>();

    if (themeController.isUser) {
      return kUserBottomNavList;
    }
    return kUserBottomNavList;
  }

  @override
  void dispose() {
    _isDisposed = true;
    pageController.dispose();
    super.dispose();
  }

  void update() {
    if (!_isDisposed) notifyListeners();
  }

  void callbackSelectTab(int tabItem) {
    final index = navItems.indexWhere((e) => e.id == tabItem);

    if (index == -1) return;

    context.read<AppController>().getUser();

    printLog("tabItem : $tabItem -> jumping to index $index");

    // PageController only attached while MainPage is showing
    if (pageController.hasClients) {
      pageController.jumpToPage(index);
    }
    currentTab = navItems[index].id;
    update();
  }

  void onPageChanged(int index) {
    currentTab = navItems[index].id;
    update();
  }
}
