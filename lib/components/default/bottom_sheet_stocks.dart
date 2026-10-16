// Project imports:
import '../../imports.dart';
import '../../models/backpack_model.dart';
import '../../models/shipment_item_model.dart';
import '../main_product/main_product_parts.dart';
import '../sub_product/sub_product_parts.dart';

/// The backpack stocks picked for 申請出貨 or 兌換PTS: how many of each (all
/// to start with), a bin for each, the total; [onConfirm] gets them on the
/// button.
class BottomSheetStocks extends StatefulWidget {
  /// Translation keys: the sheet's title and its button.
  final String title;
  final String confirmText;

  /// The button's colour; null: primary.
  final Color? confirmColor;

  final List<BackpackModel> stocks;
  final ValueChanged<List<ShipmentItemModel>> onConfirm;

  const BottomSheetStocks({
    required this.title,
    required this.confirmText,
    this.confirmColor,
    required this.stocks,
    required this.onConfirm,
    super.key,
  });

  @override
  State<BottomSheetStocks> createState() => _BottomSheetStocksState();
}

class _BottomSheetStocksState extends State<BottomSheetStocks> {
  // every piece of each stock to start with
  late final List<ShipmentItemModel> _items = [
    for (final BackpackModel stock in widget.stocks)
      ShipmentItemModel(stock: stock, quantity: stock.quantity),
  ];

  int get _totalQuantity =>
      _items.fold(0, (int sum, ShipmentItemModel item) => sum + item.quantity);

  double get _totalAmount => _items.fold(
    0,
    (double sum, ShipmentItemModel item) => sum + item.totalAmount,
  );

  /// Nothing left closes the sheet.
  void _onRemove(ShipmentItemModel item) {
    setState(() => _items.remove(item));
    if (_items.isEmpty) AppNavigator.pop(context);
  }

  void _onQuantity(ShipmentItemModel item, int quantity) {
    setState(() => item.quantity = quantity);
  }

  void _onConfirm() {
    AppNavigator.pop(context);
    widget.onConfirm(_items);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0).r,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(),
            12.heightSpace,
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (final (int index, ShipmentItemModel item)
                        in _items.indexed) ...[
                      if (index > 0) 10.heightSpace,
                      _item(item),
                    ],
                  ],
                ),
              ),
            ),
            16.heightSpace,
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.greyLight2Color,
            ),
            10.heightSpace,
            _total(),
            10.heightSpace,
            AppButtonWidget(
              text: context.tr(widget.confirmText),
              radius: 10,
              fontWeight: FontWeight.w600,
              buttonColor: widget.confirmColor,
              textColor: AppColors.whiteColor,
              padding: const EdgeInsets.symmetric(vertical: 10).r,
              onTap: _onConfirm,
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return SizedBox(
      height: 40.r,
      child: Row(
        children: [
          Expanded(
            child: AppText(
              context.tr(widget.title),
              fontSize: kFont16,
              fontWeight: FontWeight.w700,
            ),
          ),
          InkWellWrapper(
            onTap: () => AppNavigator.pop(context),
            child: Padding(
              padding: const EdgeInsets.all(4).r,
              child: Icon(
                Icons.close_rounded,
                size: 22.r,
                color: AppColors.loginTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(ShipmentItemModel item) {
    final BackpackModel stock = item.stock;
    final String? grade = stock.grade?.image;
    final double gradeHeight = 16.r;

    return Container(
      padding: const EdgeInsets.all(10).r,
      decoration: BoxDecoration(
        color: AppColors.greyBackgroundColor,
        borderRadius: BorderRadius.circular(12).r,
      ),
      child: Row(
        children: [
          Container(
            width: 52.r,
            padding: const EdgeInsets.all(3).r,
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(8).r,
            ),
            child: AspectRatio(
              aspectRatio: SubProductTile.imageAspectRatio,
              child: AppImage(
                name: stock.image,
                fit: BoxFit.contain,
                borderRadius: BorderRadius.circular(4).r,
              ),
            ),
          ),
          12.widthSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppText(
                        stock.name ?? '',
                        fontSize: kFont13,
                        fontWeight: FontWeight.w600,
                        maxLines: 2,
                        isOverflow: true,
                      ),
                    ),
                    8.widthSpace,
                    _iconButton(
                      Iconsax.trash,
                      color: context.color.primary,
                      onTap: () => _onRemove(item),
                    ),
                  ],
                ),
                6.heightSpace,
                Row(
                  children: [
                    if (grade != null) ...[
                      AppImage(
                        name: grade,
                        height: gradeHeight,
                        width:
                            gradeHeight *
                            SubProductGradeTitle.artworkAspectRatio,
                        fit: BoxFit.contain,
                      ),
                      6.widthSpace,
                    ],
                    Expanded(
                      child: AppText(
                        '${formatMainProductAmount(stock.amount)} pt',
                        fontSize: kFont14,
                        fontWeight: FontWeight.w700,
                        color: context.color.primary,
                        maxLines: 1,
                        isOverflow: true,
                      ),
                    ),
                    _quantity(item),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quantity(ShipmentItemModel item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _iconButton(
          Iconsax.minus_copy,
          onTap: item.quantity > 1
              ? () => _onQuantity(item, item.quantity - 1)
              : null,
        ),
        SizedBox(
          width: 24.r,
          child: AppText(
            '${item.quantity}',
            fontSize: kFont14,
            fontWeight: FontWeight.w700,
            textAlign: TextAlign.center,
          ),
        ),
        _iconButton(
          Iconsax.add_copy,
          onTap: item.quantity < item.stock.quantity
              ? () => _onQuantity(item, item.quantity + 1)
              : null,
        ),
      ],
    );
  }

  Widget _iconButton(IconData icon, {VoidCallback? onTap, Color? color}) {
    return InkWellWrapper(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4).r,
        child: Icon(
          icon,
          size: 18.r,
          color: onTap == null
              ? AppColors.loginHintColor.wOpacity(0.4)
              : color ?? AppColors.loginTextColor,
        ),
      ),
    );
  }

  /// 共 N 件 on the left; the coin and the total on the right.
  Widget _total() {
    final double coinSize = 20.r;

    return Row(
      children: [
        AppText(
          context.tr(AppStrings.prizeCount, args: ['$_totalQuantity']),
          fontSize: kFont14,
        ),
        12.widthSpace,
        const Spacer(),
        AppImage(
          name: AppAssets.coins,
          width: coinSize,
          height: coinSize,
          fit: BoxFit.contain,
          cacheWidth: (coinSize * MediaQuery.devicePixelRatioOf(context))
              .round(),
        ),
        4.widthSpace,
        AppText(
          formatMainProductAmount(_totalAmount),
          fontSize: kFont18,
          fontWeight: FontWeight.w700,
          color: context.color.primary,
        ),
      ],
    );
  }
}
