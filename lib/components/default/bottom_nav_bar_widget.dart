// Project imports:
import '../../controllers/main_controller.dart';
import '../../imports.dart';
import '../../models/bottom_nav_model.dart';

class BottomNavigationWidget extends StatelessWidget {
  final bool titleEnabled;

  const BottomNavigationWidget({this.titleEnabled = false, super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MainController>(
      builder: (context, mainController, _) {
        final navItems = mainController.navItems;
        final currentTab = mainController.currentTab;

        return SizedBox(
          height: titleEnabled ? kBottomNavHeight : kBottomNavigationBarHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              navItems.length,
              (index) => Expanded(
                child: _buildBottomBarItem(
                  context: context,
                  item: navItems[index],
                  currentTab: currentTab,
                  mainController: mainController,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBarItem({
    required BuildContext context,
    required BottomNavModel item,
    required int currentTab,
    required MainController mainController,
  }) {
    const double iconSize = 24;
    final isSelected = currentTab == item.id;
    final Color color = isSelected
        ? context.color.primary
        : AppColors.whiteColor;

    return InkWellWrapper(
      onTap: () {
        HapticFeedback.lightImpact();

        if (currentTab == item.id) return;
        mainController.callbackSelectTab(item.id);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? item.iconOn : item.iconOff,
            size: iconSize,
            color: color,
          ),
          if (titleEnabled && (item.title?.isNotEmpty ?? false)) ...[
            5.heightSpace,
            AppText(
              context.tr(item.title!),
              color: color,
              fontSize: kFont12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              height: 1,
              textAlign: TextAlign.center,
              isOverflow: true,
            ),
          ],
          6.heightSpace,

          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3,
            width: isSelected ? 18 : 0,
            decoration: BoxDecoration(
              color: context.color.primary,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }
}
