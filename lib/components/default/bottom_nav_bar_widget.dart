// Dart imports:
import 'dart:ui' as ui;

// Package imports:
import 'package:liquid_glass_bottom_nav/liquid_glass_bottom_nav.dart';

// Project imports:
import '../../controllers/main_controller.dart';
import '../../imports.dart';

class BottomNavigationWidget extends StatelessWidget {
  const BottomNavigationWidget({super.key});
  static const double _lowerBy = 20;

  static bool get glassSupported => ui.ImageFilter.isShaderFilterSupported;

  static double contentBottomInset(BuildContext context) =>
      glassSupported ? LiquidGlassNavBar.contentBottomInset + 20 : 12;
  //  MediaQuery.paddingOf(context).bottom

  @override
  Widget build(BuildContext context) {
    return Consumer<MainController>(
      builder: (context, mainController, _) {
        final navItems = mainController.navItems;
        final int selectedIndex = navItems
            .indexWhere((e) => e.id == mainController.currentTab)
            .clamp(0, navItems.length - 1);

        void onTap(int index) {
          HapticFeedback.lightImpact();

          final int tab = navItems[index].id;
          if (mainController.currentTab == tab) return;
          mainController.callbackSelectTab(tab);
        }

        final ThemeData theme = Theme.of(context);

        if (!glassSupported) {
          // No ripple or highlight when a tab is tapped
          return Theme(
            data: theme.copyWith(
              splashFactory: NoSplash.splashFactory,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: selectedIndex,
              backgroundColor: AppColors.whiteColor,
              selectedItemColor: context.color.primary,
              unselectedItemColor: AppColors.blackColor,
              iconSize: 26,
              selectedFontSize: kFont11,
              unselectedFontSize: kFont11,
              items: [
                for (final item in navItems)
                  BottomNavigationBarItem(
                    icon: Icon(item.iconOff),
                    activeIcon: Icon(item.iconOn),
                    label: context.tr(item.title ?? ''),
                  ),
              ],
              onTap: onTap,
            ),
          );
        }

        final MediaQueryData media = MediaQuery.of(context);

        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              brightness: Brightness.light,
            ),
          ),
          child: MediaQuery(
            data: media.copyWith(
              padding: media.padding.copyWith(
                bottom: (media.padding.bottom - _lowerBy).clamp(
                  0.0,
                  double.infinity,
                ),
              ),
            ),
            child: LiquidGlassNavBar(
              selectedIndex: selectedIndex,
              activeColor: context.color.primary,
              inactiveColor: AppColors.blackColor,
              iconSize: 26,
              labelStyle: const TextStyle(fontSize: kFont11),
              showShadow: true,
              glassColor: AppColors.whiteColor.wOpacity(0.90),
              items: [
                for (int i = 0; i < navItems.length; i++)
                  LiquidGlassNavItem(
                    id: navItems[i].id.toString(),
                    label: context.tr(navItems[i].title ?? ''),
                    icon: i == selectedIndex
                        ? navItems[i].iconOn
                        : navItems[i].iconOff,
                  ),
              ],
              onTap: onTap,
            ),
          ),
        );
      },
    );
  }
}
