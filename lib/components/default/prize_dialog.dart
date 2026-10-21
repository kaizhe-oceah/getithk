// Dart imports:
import 'dart:math' as math;

// Project imports:
import '../../imports.dart';

class PrizeDialog extends StatelessWidget {
  final String? image;
  final String? levelImage;
  final String? name;
  final double? chance;
  final double? amount;
  final bool isPsa10;

  const PrizeDialog({
    required this.image,
    this.amount,
    this.levelImage,
    this.name,
    this.chance,
    this.isPsa10 = false,
    super.key,
  });

  static Future<void> show(
    BuildContext context, {
    required String? image,
    double? amount,
    String? levelImage,
    String? name,
    double? chance,
    bool isPsa10 = false,
  }) {
    return DialogHelper<void>().showDefaultDialog(
      context2: context,
      child: PrizeDialog(
        image: image,
        amount: amount,
        levelImage: levelImage,
        name: name,
        chance: chance,
        isPsa10: isPsa10,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double dpr = MediaQuery.devicePixelRatioOf(context);
    final double coinSize = 22.r;
    final double worth = amount ?? 0;
    final double levelHeight = 36.r;

    return Dialog(
      backgroundColor: AppColors.whiteColor,
      surfaceTintColor: AppColors.transparentColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40).r,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16).r),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 20).r,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (levelImage != null)
                  AppImage(
                    name: levelImage,
                    height: levelHeight,
                    fit: BoxFit.contain,
                  ),
                const Spacer(),
                _closeButton(context),
              ],
            ),
            12.heightSpace,

            PrizePicture(
              image: image,
              isPsa10: isPsa10,
              maxHeight: screenHeight * 0.45,
            ),

            if ((name ?? '').isNotEmpty) ...[
              16.heightSpace,
              AppText(
                name!,
                fontSize: kFont16,
                fontWeight: FontWeight.w700,
                color: AppColors.loginTextColor,
                textAlign: TextAlign.center,
              ),
            ],
            if (chance != null) ...[
              4.heightSpace,
              AppText(
                context.tr(
                  AppStrings.drawChance,
                  args: [NumberFormat('0.00').format(chance)],
                ),
                fontSize: kFont12,
                color: AppColors.textLightColor,
                textAlign: TextAlign.center,
              ),
            ],
            if (worth > 0) ...[
              10.heightSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppImage(
                    name: AppAssets.coins,
                    width: coinSize,
                    height: coinSize,
                    fit: BoxFit.contain,
                    cacheWidth: (coinSize * dpr).round(),
                  ),
                  6.widthSpace,
                  AppText(
                    NumberFormat('#,##0.##').format(worth),
                    fontSize: kFont20,
                    fontWeight: FontWeight.w800,
                    color: context.color.primary,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _closeButton(BuildContext context) {
    final double size = 32.r;

    return InkWellWrapper(
      onTap: () => AppNavigator.pop(context),
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.greyLight2Color,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.close_rounded,
          size: 18.r,
          color: AppColors.textLightColor,
        ),
      ),
    );
  }
}

class PrizePicture extends StatefulWidget {
  final String? image;
  final bool isPsa10;
  final double maxHeight;

  const PrizePicture({
    required this.image,
    required this.isPsa10,
    required this.maxHeight,
    super.key,
  });

  @override
  State<PrizePicture> createState() => _PrizePictureState();
}

class _PrizePictureState extends State<PrizePicture> {
  Size? _imageSize;

  void _onImageSize(Size size) {
    if (mounted && size != _imageSize) setState(() => _imageSize = size);
  }

  @override
  Widget build(BuildContext context) {
    final double minHeight = 160.r;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final Size? imageSize = _imageSize;
        final Size box = Size(
          width,
          imageSize == null
              ? minHeight
              : (width * imageSize.height / imageSize.width).clamp(
                  minHeight,
                  math.max(minHeight, widget.maxHeight),
                ),
        );
        final Rect? picture = imageSize == null
            ? null
            : Alignment.center.inscribe(
                applyBoxFit(BoxFit.contain, imageSize, box).destination,
                Offset.zero & box,
              );
        final double dpr = MediaQuery.devicePixelRatioOf(context);

        return SizedBox.fromSize(
          size: box,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppImage(
                name: widget.image,
                fit: BoxFit.contain,
                cacheWidth: (width * dpr).round(),
                onImageSize: _onImageSize,
              ),
              if (widget.isPsa10 && picture != null)
                Positioned(
                  top: picture.top + 6.r,
                  right: box.width - picture.right + 6.r,
                  child: AppImage(
                    name: AppAssets.psa,
                    width: picture.width * 0.3,
                    fit: BoxFit.contain,
                    cacheWidth: (picture.width * 0.3 * dpr).round(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
