// Project imports:
import '../imports.dart';

class FavouritePage extends StatelessWidget {
  const FavouritePage({super.key});

  /// Also tells the bottom nav whether to use light or dark glass.
  static const Color backgroundColor = AppColors.darkBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return AppScaffold.basic(
      backgroundColor: backgroundColor,
      forceOverlayStyle: SystemUiOverlayStyle.light,
      child: SafeArea(
        child: Center(
          child: AppText(
            context.tr(AppStrings.favourite),
            fontSize: kFont18,
            fontWeight: FontWeight.w600,
            color: AppColors.whiteColor,
          ),
        ),
      ),
    );
  }
}
