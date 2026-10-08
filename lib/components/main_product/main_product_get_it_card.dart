// Project imports:
import '../../imports.dart';
import '../../models/main_product_model.dart';
import 'main_product_parts.dart';

class MainProductGetItCard extends StatelessWidget {
  final MainProductModel product;
  final VoidCallback? onDraw;

  const MainProductGetItCard({required this.product, this.onDraw, super.key});

  static const double imageAspectRatio = 1280 / 714;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(14).r,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: imageAspectRatio,
            child: AppImage(
              name: product.image,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              cacheWidth:
                  (MediaQuery.sizeOf(context).width *
                          MediaQuery.devicePixelRatioOf(context))
                      .round(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12).r,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (product.tags.isNotEmpty) ...[
                  MainProductTags(tags: product.tags),
                  10.heightSpace,
                ],
                MainProductPriceAndStock(product: product),
                if (product.hasTopupUnlock) ...[
                  12.heightSpace,
                  MainProductTopupUnlock(product: product),
                ],
                12.heightSpace,
                MainProductDrawButton(product: product, onDraw: onDraw),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
