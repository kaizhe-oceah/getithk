// Project imports:
import '../imports.dart';

/// The 活動 tab.
class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold.basic(
      backgroundColor: AppColors.whiteColor,
      forceOverlayStyle: SystemUiOverlayStyle.dark,
      child: SafeArea(
        child: Center(
          child: AppText(
            context.tr(AppStrings.activity),
            fontSize: kFont18,
            fontWeight: FontWeight.w600,
            color: AppColors.blackColor,
          ),
        ),
      ),
    );
  }
}
