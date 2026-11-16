// Package imports:
import 'package:haptic_feedback/haptic_feedback.dart';

// Project imports:
import '../../imports.dart';
import '../../models/main_product_model.dart';
import 'main_product_parts.dart';

/// A product in a two-column grid. It fills the height it's given, so the
/// buttons of two cards side by side line up; give it a bounded height
/// (e.g. an [IntrinsicHeight] row).
class MainProductGridCard extends StatelessWidget {
  final MainProductModel product;
  final ValueChanged<int>? onDraw;
  final VoidCallback? onTopUp;
  final VoidCallback? onTap;

  const MainProductGridCard({
    required this.product,
    this.onDraw,
    this.onTopUp,
    this.onTap,
    super.key,
  });

  static const double radius = 14;
  static EdgeInsets get padding => const EdgeInsets.fromLTRB(10, 8, 10, 10).r;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? onTap = this.onTap;

    return InkWellWrapper(
      pressedScale: 0.96,
      onTap: onTap == null
          ? null
          : () {
              Haptics.vibrate(HapticsType.soft);
              onTap();
            },
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: context.color.surface,
          borderRadius: BorderRadius.circular(radius).r,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: MainProductImage.bannerAspectRatio,
              child: MainProductImage(image: product.image),
            ),
            Expanded(
              child: Padding(
                padding: padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (product.tags.isNotEmpty) ...[
                      MainProductTags(tags: product.tags, dense: true),
                      8.heightSpace,
                    ],
                    MainProductPrice(product: product),
                    6.heightSpace,
                    MainProductStock(
                      product: product,
                      alignment: CrossAxisAlignment.start,
                    ),
                    if (product.hasTopupUnlock) ...[
                      10.heightSpace,
                      MainProductTopupUnlock(product: product, dense: true),
                    ],
                    10.heightSpace,
                    const Spacer(),
                    MainProductDrawButtons(
                      product: product,
                      onDraw: onDraw,
                      onTopUp: onTopUp,
                      dense: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainProductGridCardSkeleton extends StatelessWidget {
  const MainProductGridCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(6).r;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.color.surface,
        borderRadius: BorderRadius.circular(MainProductGridCard.radius).r,
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
              padding: MainProductGridCard.padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Bone(width: 80.r, height: 18.r, borderRadius: radius),
                  8.heightSpace,
                  Bone(height: 8.r, borderRadius: radius),
                  16.heightSpace,
                  Bone(height: 30.r, borderRadius: radius),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
