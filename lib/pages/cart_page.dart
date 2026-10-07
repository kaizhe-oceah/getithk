// Project imports:
import '../imports.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold.basic(
      backgroundColor: AppColors.whiteColor,
      forceOverlayStyle: SystemUiOverlayStyle.dark,
      child: SafeArea(
        child: Center(
          child: AppText(
            context.tr(AppStrings.cart),
            fontSize: kFont18,
            fontWeight: FontWeight.w600,
            color: AppColors.blackColor,
          ),
        ),
      ),
    );
  }
}
