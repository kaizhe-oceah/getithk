// Dart imports:
import 'dart:ui' as ui;

// Package imports:
import 'package:liquid_glass_bottom_nav/liquid_glass_bottom_nav.dart';

// Project imports:
import '../../controllers/main_controller.dart';
import '../../imports.dart';

class BottomNavigationWidget extends StatelessWidget {
  const BottomNavigationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MainController>(
      builder: (context, mainController, _) {
        final navItems = mainController.navItems;
        final int selectedIndex = navItems
            .indexWhere((e) => e.id == mainController.currentTab)
            .clamp(0, navItems.length - 1);

        // creating the glass shader throws when Impeller is off
        final bool glassSupported = ui.ImageFilter.isShaderFilterSupported;

        // white glass over light pages, smoked glass over dark ones
        final bool isDarkBackground =
            ThemeData.estimateBrightnessForColor(
              navItems[selectedIndex].backgroundColor,
            ) ==
            Brightness.dark;

        final Widget navBar = LiquidGlassNavBar(
          impellerSupported: glassSupported,
          selectedIndex: selectedIndex,
          activeColor: context.color.primary,
          inactiveColor: isDarkBackground
              ? AppColors.whiteColor
              : AppColors.blackColor,
          iconSize: 28,
          labelStyle: const TextStyle(fontSize: kFont11),
          showShadow: true,
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

        return Theme(
          data: theme.copyWith(
            colorScheme: isDarkBackground
                ? theme.colorScheme.copyWith(
                    brightness: Brightness.dark,
                    surfaceContainerHighest: AppColors.bottomNavColor,
                    outlineVariant: AppColors.bottomNavBorderColor,
                  )
                : theme.colorScheme.copyWith(brightness: Brightness.light),
          ),
          child: glassSupported
              ? navBar
              : Positioned(left: 0, right: 0, bottom: 0, child: navBar),
        );
      },
    );
  }
}
