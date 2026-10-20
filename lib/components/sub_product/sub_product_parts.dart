// Project imports:
import '../../imports.dart';
import '../default/prize_dialog.dart';
import '../../models/sub_product_model.dart';

class SubProductGradeTitle extends StatelessWidget {
  final int? gradeId;
  final String? name;

  const SubProductGradeTitle({this.gradeId, this.name, super.key});

  /// The grade artwork's width over its height.
  static const double artworkAspectRatio = 548 / 272;

  static String? artworkFor(int? gradeId) =>
      ProductGrade.fromValue(gradeId)?.image;

  static const LinearGradient _rainbow = LinearGradient(
    colors: [
      Color(0xFFFF3B3B),
      Color(0xFFFF9F1C),
      Color(0xFFFFE600),
      Color(0xFF3DDC84),
      Color(0xFF2F9BFF),
      Color(0xFFB44BFF),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final String? artwork = artworkFor(gradeId);
    if (artwork != null) {
      final double width = 40.r * artworkAspectRatio;

      return AppImage(
        name: artwork,
        width: width,
        height: 40.r,
        fit: BoxFit.contain,
        cacheWidth: (width * MediaQuery.devicePixelRatioOf(context)).round(),
      );
    }

    final String text = name ?? '';
    if (text.isEmpty) return const SizedBox.shrink();

    final TextStyle style = TextStyle(
      fontSize: kFont24.sp,
      fontWeight: FontWeight.w900,
      height: 1.2,
    );
    return Stack(
      children: [
        Text(
          text,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 5.r
              ..strokeJoin = StrokeJoin.round
              ..color = AppColors.whiteColor,
            shadows: [
              Shadow(
                color: AppColors.blackColor.wOpacity(0.25),
                blurRadius: 4.r,
                offset: Offset(0, 1.r),
              ),
            ],
          ),
        ),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: _rainbow.createShader,
          child: Text(text, style: style),
        ),
      ],
    );
  }
}

class SubProductQuantityBadge extends StatelessWidget {
  final int quantity;

  const SubProductQuantityBadge({required this.quantity, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3).r,
      decoration: BoxDecoration(
        color: AppColors.quantityBadgeColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ).r,
      ),
      child: AppText(
        'x${NumberFormat('#,##0').format(quantity)}',
        fontSize: kFont12,
        fontWeight: FontWeight.w500,
        color: AppColors.whiteColor,
      ),
    );
  }
}

class SubProductTile extends StatefulWidget {
  final SubProductModel product;
  final double width;

  /// What its dialog shows, on a tap: the grade's artwork, and the chance
  /// of drawing it.
  final bool showGradeInDialog;
  final bool showChanceInDialog;

  const SubProductTile({
    required this.product,
    required this.width,
    this.showGradeInDialog = true,
    this.showChanceInDialog = false,
    super.key,
  });
  static const double imageAspectRatio = 63 / 88;

  @override
  State<SubProductTile> createState() => _SubProductTileState();
}

class _SubProductTileState extends State<SubProductTile> {
  Size? _imageSize;

  @override
  void didUpdateWidget(SubProductTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.image != widget.product.image) _imageSize = null;
  }

  void _onImageSize(Size size) {
    if (mounted && size != _imageSize) setState(() => _imageSize = size);
  }

  @override
  Widget build(BuildContext context) {
    final SubProductModel product = widget.product;
    final double width = widget.width;
    // 僅限運送 and PSA 10, side by side at the same size
    final double badgeSize = width * 0.34 * 402 / 544;
    final double dpr = MediaQuery.devicePixelRatioOf(context);
    final Size box = Size(width, width / SubProductTile.imageAspectRatio);
    final Size? imageSize = _imageSize;
    final Rect? picture = imageSize == null
        ? null
        : Alignment.center.inscribe(
            applyBoxFit(BoxFit.contain, imageSize, box).destination,
            Offset.zero & box,
          );

    return SizedBox(
      width: width,
      child: Column(
        children: [
          SizedBox.fromSize(
            size: box,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AppImage(
                  name: product.image,
                  fit: BoxFit.contain,
                  borderRadius: BorderRadius.circular(6).r,
                  onTap: () => PrizeDialog.show(
                    context,
                    image: product.image,
                    amount: product.amount,
                    levelImage: widget.showGradeInDialog
                        ? SubProductGradeTitle.artworkFor(product.gradeId)
                        : null,
                    name: product.name,
                    chance: widget.showChanceInDialog
                        ? product.displayPercentage
                        : null,
                    isPsa10: product.isPsa10,
                  ),
                  cacheWidth: (width * MediaQuery.devicePixelRatioOf(context))
                      .round(),
                  onImageSize: _onImageSize,
                ),
                if (product.quantity != null && picture != null)
                  Positioned(
                    right: box.width - picture.right + 4.r,
                    bottom: box.height - picture.bottom + 4.r,
                    child: SubProductQuantityBadge(quantity: product.quantity!),
                  ),
                // top right: 僅限運送, then the PSA badge after it
                if (product.isDeliveryOnly || product.isPsa10)
                  Positioned(
                    top: 4.r,
                    right: 4.r,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (product.isDeliveryOnly)
                          AppImage(
                            name: AppAssets.deliveryOnly,
                            width: badgeSize,
                            height: badgeSize,
                            fit: BoxFit.contain,
                            cacheWidth: (badgeSize * dpr).round(),
                          ),
                        if (product.isDeliveryOnly && product.isPsa10)
                          4.widthSpace,
                        if (product.isPsa10)
                          AppImage(
                            name: AppAssets.psa,
                            width: badgeSize,
                            height: badgeSize,
                            fit: BoxFit.contain,
                            cacheWidth: (badgeSize * dpr).round(),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
