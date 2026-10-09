// Dart imports:
import 'dart:math' as math;

// Project imports:
import '../../imports.dart';

/// A prize up close: its grade's artwork at the top left, a ✕ at the top
/// right, then the picture, its name and what it's worth in pts. A tap
/// outside closes it too.
class PrizeDialog extends StatelessWidget {
  final String? image;

  /// The grade's artwork (一等獎, …): an asset or a URL; none if null.
  final String? levelImage;
  final String? name;
  final double amount;

  /// A PSA 10 graded card: the PSA 10 badge on the picture's corner.
  final bool isPsa10;

  const PrizeDialog({
    required this.image,
    required this.amount,
    this.levelImage,
    this.name,
    this.isPsa10 = false,
    super.key,
  });

  static Future<void> show(
    BuildContext context, {
    required String? image,
    required double amount,
    String? levelImage,
    String? name,
    bool isPsa10 = false,
  }) {
    return DialogHelper<void>().showDefaultDialog(
      context2: context,
      child: PrizeDialog(
        image: image,
        amount: amount,
        levelImage: levelImage,
        name: name,
        isPsa10: isPsa10,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double dpr = MediaQuery.devicePixelRatioOf(context);
    final double coinSize = 22.r;
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

            _PrizePicture(
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
                  NumberFormat('#,##0.##').format(amount),
                  fontSize: kFont20,
                  fontWeight: FontWeight.w800,
                  color: context.color.primary,
                ),
              ],
            ),
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

/// The whole prize picture, as tall as it needs (160 while it loads) up to
/// [maxHeight], with the PSA 10 badge on the picture's own corner.
class _PrizePicture extends StatefulWidget {
  final String? image;
  final bool isPsa10;
  final double maxHeight;

  const _PrizePicture({
    required this.image,
    required this.isPsa10,
    required this.maxHeight,
  });

  @override
  State<_PrizePicture> createState() => _PrizePictureState();
}

class _PrizePictureState extends State<_PrizePicture> {
  /// The picture's own size once it has loaded.
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
        // where the picture is drawn: whole, centred in the box
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
