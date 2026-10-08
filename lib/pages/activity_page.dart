// Project imports:
import '../imports.dart';

class FavouritePage extends StatelessWidget {
  const FavouritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold.basic(
      backgroundColor: AppColors.whiteColor,
      forceOverlayStyle: SystemUiOverlayStyle.dark,
      child: SafeArea(
        child: Center(
          child: AppText(
            context.tr(AppStrings.favourite),
            fontSize: kFont18,
            fontWeight: FontWeight.w600,
            color: AppColors.blackColor,
          ),
        ),
      ),
    );
  }
}
