// Project imports:
import '../../imports.dart';
import '../../models/product_tag_model.dart';

/// A product tag as a pill: plain grey (outline and text) until
/// [selected], then in the tag's own color, outline and text, on a light
/// tint of it. With [onRemove] it ends in a ✕, and tapping it removes the
/// tag.
class ProductTagChip extends StatelessWidget {
  final ProductTagModel tag;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  /// The name's size; the ✕ follows it.
  final double fontSize;

  static const Color _plainBorder = Color(0xFFDCE3EC);
  static const Color _plainText = Color(0xFFA3AFBF);

  const ProductTagChip({
    required this.tag,
    this.selected = false,
    this.onTap,
    this.onRemove,
    this.fontSize = kFont12,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = tag.colorValue ?? AppColors.greyColor;
    // a light color (e.g. yellow) reads better as text a little darker; the
    // outline and tint stay the tag's own
    final Color tagText = color.computeLuminance() > 0.55
        ? darken(color, 0.15)
        : color;
    final Color content = selected ? tagText : _plainText;
    final bool removable = onRemove != null;
    final double iconSize = (fontSize + 2).r;

    return InkWellWrapper(
      onTap: onRemove ?? onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(12, 5, removable ? 8 : 12, 5).r,
        decoration: BoxDecoration(
          color: selected ? color.wOpacity(0.1) : AppColors.whiteColor,
          border: Border.all(
            color: selected ? color : _plainBorder,
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // one weight either way, so picking a tag doesn't widen it
            AppText(
              tag.name ?? '',
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: content,
            ),
            if (removable) ...[
              4.widthSpace,
              Icon(Icons.close_rounded, size: iconSize, color: content),
            ],
          ],
        ),
      ),
    );
  }
}
