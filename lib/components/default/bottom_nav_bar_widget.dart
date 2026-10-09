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

  @override
  Widget build(BuildContext context) {
    return Consumer<MainController>(
      builder: (context, mainController, _) {
        final navItems = mainController.navItems;
        final int selectedIndex = navItems
            .indexWhere((e) => e.id == mainController.currentTab)
            .clamp(0, navItems.length - 1);

        final bool glassSupported = ui.ImageFilter.isShaderFilterSupported;

        final Widget navBar = LiquidGlassNavBar(
          impellerSupported: glassSupported,
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
          onTap: (index) {
            HapticFeedback.lightImpact();

            final int tab = navItems[index].id;
            if (mainController.currentTab == tab) return;
            mainController.callbackSelectTab(tab);
          },
        );

        final ThemeData theme = Theme.of(context);
        final MediaQueryData media = MediaQuery.of(context);

        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              brightness: Brightness.light,
            ),
          ),
          child: glassSupported
              ? MediaQuery(
                  data: media.copyWith(
                    padding: media.padding.copyWith(
                      bottom: (media.padding.bottom - _lowerBy).clamp(
                        0.0,
                        double.infinity,
                      ),
                    ),
                  ),
                  child: navBar,
                )
              : Positioned(left: 0, right: 0, bottom: 0, child: navBar),
        );
      },
    );
  }
}
