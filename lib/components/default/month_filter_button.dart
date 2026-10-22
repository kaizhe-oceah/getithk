// Project imports:
import '../../imports.dart';
import 'app_bar_action_button.dart';

/// The app bar's month filter: a calendar, dotted once a [month] is picked.
class MonthFilterButton extends StatelessWidget {
  final DateTime? month;
  final VoidCallback onTap;

  const MonthFilterButton({
    required this.month,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBarActionButton(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            Iconsax.calendar_1_copy,
            size: 22.r,
            color: AppColors.loginTextColor,
          ),
          if (month != null)
            Positioned(
              top: -1.r,
              right: -1.r,
              child: Container(
                width: 9.r,
                height: 9.r,
                decoration: BoxDecoration(
                  color: context.color.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.whiteColor, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
