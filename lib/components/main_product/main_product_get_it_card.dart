// Project imports:
import '../../imports.dart';
import '../../models/main_product_model.dart';
import 'main_product_parts.dart';

class MainProductGetItCard extends StatelessWidget {
  final MainProductModel product;
  final ValueChanged<int>? onDraw;
  final VoidCallback? onTap;

  const MainProductGetItCard({
    required this.product,
    this.onDraw,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWellWrapper(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(14).r,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MainProductImage(image: product.image),
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
                  MainProductDrawButtons(product: product, onDraw: onDraw),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
