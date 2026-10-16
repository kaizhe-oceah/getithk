// Project imports:
import '../../imports.dart';
import '../../models/backpack_model.dart';
import '../main_product/main_product_parts.dart';
import '../sub_product/sub_product_parts.dart';

class BackpackStockCard extends StatelessWidget {
  final BackpackModel stock;
  final bool selected;
  final bool isLoading;

  final VoidCallback? onSelect;

  const BackpackStockCard({
    required this.stock,
    this.selected = false,
    this.isLoading = false,
    this.onSelect,
    super.key,
  });

  static const double _gradeHeight = 24;

  @override
  Widget build(BuildContext context) {
    final Color primary = context.color.primary;
    final BackpackModel shown = isLoading ? BackpackModel.placeholder() : stock;

    return InkWellWrapper(
      onTap: isLoading ? null : onSelect,
      child: Container(
        padding: const EdgeInsets.all(6).r,
        decoration: BoxDecoration(
          color: selected && !isLoading
              ? primary.wOpacity(0.09)
              : AppColors.whiteColor,
          borderRadius: BorderRadius.circular(8).r,
          border: Border.all(
            color: selected && !isLoading ? primary : AppColors.greyLight2Color,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackColor.wOpacity(0.06),
              blurRadius: 6.r,
              offset: Offset(0, 2.r),
            ),
          ],
        ),
        child: AppSkeletonizer(
          enabled: isLoading,
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: SubProductTile.imageAspectRatio,
                child: isLoading
                    ? Bone(borderRadius: BorderRadius.circular(4).r)
                    : _image(context),
              ),
              6.heightSpace,
              AppText(
                shown.name ?? '',
                fontSize: kFont12,
                color: AppColors.loginTextColor,
                textAlign: TextAlign.center,
                maxLines: 1,
                isOverflow: true,
              ),
              2.heightSpace,
              AppText(
                '${formatMainProductAmount(shown.amount)} pt',
                fontSize: kFont12,
                fontWeight: FontWeight.w700,
                color: primary,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _image(BuildContext context) {
    final ProductGrade? grade = stock.grade;

    return Stack(
      fit: StackFit.expand,
      children: [
        AppImage(
          name: stock.image,
          fit: BoxFit.contain,
          borderRadius: BorderRadius.circular(4).r,
        ),
        if (grade != null || stock.isDeliveryOnly || onSelect != null)
          Positioned(
            top: 0,
            left: 0,
            right: 4.r,
            height: _gradeHeight.r,
            child: Row(
              children: [
                if (grade != null) _grade(context, grade),
                if (stock.isDeliveryOnly) ...[
                  if (grade != null) 2.widthSpace,
                  const DeliveryOnlyBadge(size: _gradeHeight),
                ],
                const Spacer(),
                if (onSelect != null)
                  BackpackCheckBox(value: selected, size: 16),
              ],
            ),
          ),
        Positioned(
          right: 0,
          bottom: 0,
          child: SubProductQuantityBadge(quantity: stock.quantity),
        ),
      ],
    );
  }

  Widget _grade(BuildContext context, ProductGrade grade) {
    final double width =
        _gradeHeight.r * SubProductGradeTitle.artworkAspectRatio;

    return AppImage(
      name: grade.image,
      width: width,
      height: _gradeHeight.r,
      fit: BoxFit.contain,
      cacheWidth: (width * MediaQuery.devicePixelRatioOf(context)).round(),
    );
  }
}

/// 僅限運送: a prize that can only be shipped, not exchanged for PTS.
class DeliveryOnlyBadge extends StatelessWidget {
  final double size;

  const DeliveryOnlyBadge({this.size = 20, super.key});

  @override
  Widget build(BuildContext context) {
    final double side = size.r;

    return AppImage(
      name: AppAssets.deliveryOnly,
      width: side,
      height: side,
      fit: BoxFit.contain,
      cacheWidth: (side * MediaQuery.devicePixelRatioOf(context)).round(),
    );
  }
}

class BackpackCheckBox extends StatelessWidget {
  final bool value;
  final double size;

  const BackpackCheckBox({required this.value, this.size = 18, super.key});

  static const Color _border = Color(0xFFDCE3EC);

  @override
  Widget build(BuildContext context) {
    final Color primary = context.color.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: size.r,
      height: size.r,
      decoration: BoxDecoration(
        color: value ? primary : AppColors.whiteColor,
        borderRadius: BorderRadius.circular(4).r,
        border: Border.all(color: value ? primary : _border, width: 1.2),
      ),
      child: value
          ? Icon(
              Icons.check_rounded,
              size: (size - 4).r,
              color: AppColors.whiteColor,
            )
          : null,
    );
  }
}

class BackpackSelectAll extends StatelessWidget {
  final String label;
  final bool value;
  final bool enabled;
  final VoidCallback onTap;

  const BackpackSelectAll({
    required this.label,
    required this.value,
    required this.onTap,
    this.enabled = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWellWrapper(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            BackpackCheckBox(value: value),
            6.widthSpace,
            AppText(
              context.tr(label),
              fontSize: kFont13,
              fontWeight: FontWeight.w600,
              color: AppColors.loginTextColor,
            ),
          ],
        ),
      ),
    );
  }
}

class BackpackCheckoutRow extends StatelessWidget {
  final double amount;
  final bool hasSelection;
  final bool canRequestShipment;
  final bool canExchange;
  final VoidCallback onRequestShipment;
  final VoidCallback onExchange;

  const BackpackCheckoutRow({
    required this.amount,
    required this.hasSelection,
    required this.canRequestShipment,
    required this.canExchange,
    required this.onRequestShipment,
    required this.onExchange,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Color primary = context.color.primary;

    return Row(
      children: [
        Expanded(flex: 3, child: _total(context)),
        10.widthSpace,
        Expanded(
          flex: 2,
          child: _button(
            context,
            AppStrings.requestShipment,
            color: canRequestShipment
                ? AppColors.blackColor
                : AppColors.greyBackgroundColor,
            textColor: canRequestShipment
                ? AppColors.whiteColor
                : AppColors.loginHintColor,
            onTap: onRequestShipment,
          ),
        ),
        10.widthSpace,
        Expanded(
          flex: 2,
          child: _button(
            context,
            AppStrings.exchangePts,
            color: canExchange ? primary : primary.wOpacity(0.15),
            textColor: canExchange ? AppColors.whiteColor : primary,
            onTap: onExchange,
          ),
        ),
      ],
    );
  }

  /// 合計 over the amount, which counts its way to a new one; grey until
  /// something is selected.
  Widget _total(BuildContext context) {
    final double coinSize = 20.r;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          context.tr(AppStrings.selectedTotal),
          fontSize: kFont12,
          color: AppColors.textLightColor,
        ),
        2.heightSpace,
        Row(
          children: [
            AppImage(
              name: AppAssets.coins,
              width: coinSize,
              height: coinSize,
              fit: BoxFit.contain,
              cacheWidth: (coinSize * MediaQuery.devicePixelRatioOf(context))
                  .round(),
            ),
            4.widthSpace,
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: amount),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  builder: (context, value, _) => AppText(
                    formatMainProductAmount(value),
                    fontSize: kFont18,
                    fontWeight: FontWeight.w700,
                    color: hasSelection
                        ? context.color.primary
                        : AppColors.loginHintColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _button(
    BuildContext context,
    String text, {
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return AppButtonWidget(
      radius: 10,
      buttonColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12).r,
      onTap: onTap,
      builder: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: AppText(
            context.tr(text),
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
