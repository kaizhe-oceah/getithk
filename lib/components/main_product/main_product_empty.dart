// Project imports:
import '../../imports.dart';

class MainProductEmpty extends StatelessWidget {
  final VoidCallback? onClearFilter;

  const MainProductEmpty({this.onClearFilter, super.key});

  @override
  Widget build(BuildContext context) {
    final bool filtered = onClearFilter != null;
    const Color white = AppColors.whiteColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 32).r,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            context.tr(
              filtered ? AppStrings.noMatchingProducts : AppStrings.noProducts,
            ),
            fontSize: kFont16,
            fontWeight: FontWeight.w700,
            color: white,
            textAlign: TextAlign.center,
          ),
          6.heightSpace,
          AppText(
            context.tr(
              filtered
                  ? AppStrings.noMatchingProductsHint
                  : AppStrings.noProductsHint,
            ),
            fontSize: kFont13,
            color: white,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
