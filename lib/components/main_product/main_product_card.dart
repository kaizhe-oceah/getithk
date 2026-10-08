// Project imports:
import '../../imports.dart';
import '../../models/main_product_model.dart';
import 'main_product_get_it_card.dart';

/// A main product, in its category's own card design: each
/// product_category_id gets its card here. A new design is a new
/// MainProduct…Card (built from main_product_parts.dart) and a case below.
class MainProductCard extends StatelessWidget {
  final MainProductModel product;
  final VoidCallback? onDraw;

  const MainProductCard({required this.product, this.onDraw, super.key});

  static const int getItCategoryId = 1;

  @override
  Widget build(BuildContext context) {
    return switch (product.categoryId) {
      getItCategoryId => MainProductGetItCard(product: product, onDraw: onDraw),

      _ => MainProductGetItCard(product: product, onDraw: onDraw),
    };
  }
}

class MainProductCardSkeleton extends StatelessWidget {
  const MainProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(8).r;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(14).r,
      ),
      child: AppSkeletonizer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AspectRatio(
              aspectRatio: MainProductGetItCard.imageAspectRatio,
              child: Bone(),
            ),
            Padding(
              padding: const EdgeInsets.all(12).r,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Bone(width: 180.r, height: 22.r, borderRadius: radius),
                  12.heightSpace,
                  Bone(height: 22.r, borderRadius: radius),
                  12.heightSpace,
                  Bone(height: 46.r, borderRadius: radius),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
