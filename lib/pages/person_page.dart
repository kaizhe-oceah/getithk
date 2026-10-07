// Project imports:
import '../imports.dart';

class PersonPage extends StatelessWidget {
  const PersonPage({super.key});

  /// Also tells the bottom nav whether to use light or dark glass.
  static const Color backgroundColor = AppColors.darkBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppController>().user;

    return AppScaffold.basic(
      backgroundColor: backgroundColor,
      forceOverlayStyle: SystemUiOverlayStyle.light,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kHorizontalPadding).r,
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
