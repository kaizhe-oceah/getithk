// Project imports:
import '../../imports.dart';
import '../../models/main_product_model.dart';
import 'main_product_get_it_card.dart';
import 'main_product_parts.dart';

class MainProductCard extends StatelessWidget {
  final MainProductModel product;
  final ValueChanged<int>? onDraw;
  final VoidCallback? onTap;

  const MainProductCard({
    required this.product,
    this.onDraw,
    this.onTap,
    super.key,
  });

  static const int getItCategoryId = 1;

  @override
  Widget build(BuildContext context) {
    return switch (product.categoryId) {
      getItCategoryId => MainProductGetItCard(
        product: product,
        onDraw: onDraw,
        onTap: onTap,
      ),

      _ => MainProductGetItCard(product: product, onDraw: onDraw, onTap: onTap),
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
              aspectRatio: MainProductImage.bannerAspectRatio,
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
