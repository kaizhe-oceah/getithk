// Project imports:
import '../imports.dart';
import '../models/bottom_nav_model.dart';

/// 🏠 User navigation setup
const List<BottomNavModel> kUserBottomNavList = [
  BottomNavModel(
    id: kBottomNavHome,
    title: AppStrings.home,
    iconOn: Icons.home_outlined,
    iconOff: Icons.home_outlined,
    page: _HomeTab(),
  ),
  BottomNavModel(
    id: kBottomNavProfile,
    title: AppStrings.profile,
    iconOn: Icons.person_outline_rounded,
    iconOff: Icons.person_outline_rounded,
    page: _ProfileTab(),
  ),
];

// TODO(getithk): replace these placeholder tabs with the real pages.
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return AppScaffold.basic(
      backgroundColor: AppColors.darkBackgroundColor,
      forceOverlayStyle: SystemUiOverlayStyle.light,
      child: SafeArea(
        child: Center(
          child: AppText(
            context.tr(AppStrings.home),
            fontSize: kFont18,
            fontWeight: FontWeight.w600,
            color: AppColors.whiteColor,
          ),
        ),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppController>().user;

    return AppScaffold.basic(
      backgroundColor: AppColors.darkBackgroundColor,
      forceOverlayStyle: SystemUiOverlayStyle.light,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: kHorizontalPadding,
          ).r,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppText(
                user?.name ?? context.tr(AppStrings.guest),
                fontSize: kFont18,
                fontWeight: FontWeight.w600,
                color: AppColors.whiteColor,
                textAlign: TextAlign.center,
              ),
              30.heightSpace,
              AppButtonWidget(
                text: context.tr(AppStrings.logout),
                gradient: AppColors.brandGradientColor,
                radius: 14.r,
                textSize: kFont15,
                textColor: AppColors.whiteColor,
                padding: const EdgeInsets.symmetric(vertical: 14).r,
                onTap: BottomSheetHelper.logout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
