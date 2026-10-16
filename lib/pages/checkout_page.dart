// Project imports:
import '../components/main_product/main_product_parts.dart';
import '../components/sub_product/sub_product_parts.dart';
import '../controllers/checkout_controller.dart';
import '../imports.dart';
import '../models/address_model.dart';
import '../models/backpack_model.dart';
import '../models/shipment_item_model.dart';

class CheckoutPage extends StatelessWidget {
  final List<ShipmentItemModel> items;

  const CheckoutPage({required this.items, super.key});

  /// The cards' padding; with their 1px border, where their text starts and
  /// ends.
  static const double _cardPadding = 14;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CheckoutController(items: items),
      child: AppScaffold.basic(
        backgroundColor: AppColors.whiteColor,
        forceOverlayStyle: SystemUiOverlayStyle.dark,
        headerWidgets: [
          AppBarWidget(
            text: context.tr(AppStrings.confirmShipmentDetails),
            backgroundColor: AppColors.whiteColor,
            leading: const AppBarBackButton(),
          ),
        ],
        child: Consumer<CheckoutController>(
          builder: (context, controller, _) => _content(context, controller),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, CheckoutController controller) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              kHorizontalPadding,
              10,
              kHorizontalPadding,
              20,
            ).r,
            children: [
              _address(context, controller),
              14.heightSpace,
              _shippingFee(context, controller),
              kHorizontalPadding.heightSpace,
              _itemsTotal(context, controller),
              12.heightSpace,
              _cards(controller),
            ],
          ),
        ),
        _submitBar(context, controller),
      ],
    );
  }

  Widget _address(BuildContext context, CheckoutController controller) {
    final Color primary = context.color.primary;

    return InkWellWrapper(
      onTap: controller.onAddress,
      child: Container(
        padding: const EdgeInsets.all(_cardPadding).r,
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(14).r,
          border: Border.all(color: AppColors.greyLight2Color),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackColor.wOpacity(0.06),
              blurRadius: 6.r,
              offset: Offset(0, 2.r),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Iconsax.truck_fast, size: 20.r, color: primary),
                      8.widthSpace,
                      AppText(
                        context.tr(AppStrings.shippingAddress),
                        fontSize: kFont14,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                  8.heightSpace,
                  _addressDetails(context, controller),
                ],
              ),
            ),
            8.widthSpace,
            Icon(Iconsax.arrow_right_3_copy, size: 16.r, color: primary),
          ],
        ),
      ),
    );
  }

  /// The name and phone, the address under it; a prompt to add one when
  /// there's none. A skeleton while it loads.
  Widget _addressDetails(BuildContext context, CheckoutController controller) {
    final AddressModel? address = controller.isAddressLoading
        ? AddressModel.placeholder()
        : controller.address;

    if (address == null) {
      return AppText(
        context.tr(AppStrings.addShippingAddress),
        fontSize: kFont12,
        color: AppColors.loginHintColor,
      );
    }

    return AppSkeletonizer(
      enabled: controller.isAddressLoading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            '${address.name ?? ''} (${address.phone})',
            fontSize: kFont13,
            fontWeight: FontWeight.w700,
          ),
          4.heightSpace,
          AppText(
            address.address ?? '',
            fontSize: kFont12,
            color: AppColors.textLightColor,
          ),
        ],
      ),
    );
  }

  Widget _shippingFee(BuildContext context, CheckoutController controller) {
    final TextStyle style = TextStyle(
      fontSize: kFont11.sp,
      color: AppColors.loginHintColor,
      height: 1.6,
    );
    final List<String> parts = context
        .tr(AppStrings.shippingAgreement)
        .split('{}');
    final double? threshold = controller.shippingSetting?.freeShippingThreshold;

    return Container(
      padding: const EdgeInsets.all(_cardPadding).r,
      decoration: BoxDecoration(
        color: AppColors.greyBackgroundColor,
        borderRadius: BorderRadius.circular(14).r,
        border: Border.all(color: AppColors.greyBackgroundColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      context.tr(AppStrings.shippingFee),
                      fontSize: kFont14,
                      fontWeight: FontWeight.w600,
                    ),
                    if (threshold != null) ...[
                      2.heightSpace,
                      AppText(
                        context.tr(
                          AppStrings.freeShippingOver,
                          args: ['${formatMainProductAmount(threshold)} pt'],
                        ),
                        fontSize: kFont12,
                        color: context.color.primary,
                      ),
                    ],
                  ],
                ),
              ),
              8.widthSpace,
              AppSkeletonizer(
                enabled: controller.isLoading,
                child: _shippingFeeAmount(context, controller),
              ),
            ],
          ),
          12.heightSpace,
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.greyLightColor,
          ),
          12.heightSpace,
          AppText(
            context.tr(AppStrings.shippingFeeDescription),
            fontSize: kFont11,
            color: AppColors.loginHintColor,
          ),
          4.heightSpace,
          Text.rich(
            TextSpan(
              style: style,
              children: [
                for (int i = 0; i < parts.length; i++) ...[
                  TextSpan(text: parts[i]),
                  if (i < parts.length - 1)
                    TextSpan(
                      text: context.tr(AppStrings.termsOfService),
                      style: style.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.loginTextColor,
                      ),
                      recognizer: controller.termsRecognizer,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The fee; past the free-shipping threshold, it crossed out and 免費.
  Widget _shippingFeeAmount(
    BuildContext context,
    CheckoutController controller,
  ) {
    if (!controller.isFreeShipping) {
      return _coinAmount(context, controller.shippingFee);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          formatMainProductAmount(controller.shippingSetting?.shippingFee ?? 0),
          fontSize: kFont13,
          color: AppColors.loginHintColor,
          decoration: TextDecoration.lineThrough,
        ),
        6.widthSpace,
        AppText(
          context.tr(AppStrings.free),
          fontSize: kFont16,
          fontWeight: FontWeight.w600,
          color: context.color.primary,
        ),
      ],
    );
  }

  Widget _itemsTotal(BuildContext context, CheckoutController controller) {
    return Row(
      children: [
        Expanded(
          child: AppText(
            context.tr(
              AppStrings.itemsTotal,
              args: ['${controller.totalQuantity}'],
            ),
            fontSize: kFont14,
            fontWeight: FontWeight.w600,
          ),
        ),
        _coinAmount(context, controller.totalAmount),
      ],
    );
  }

  Widget _cards(CheckoutController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double spacing = 10.r;
        final double tileWidth = (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final ShipmentItemModel item in controller.items)
              _card(context, item, width: tileWidth),
          ],
        );
      },
    );
  }

  /// One per card, its grade at the top right and how many at the bottom
  /// right, as the backpack shows them.
  Widget _card(
    BuildContext context,
    ShipmentItemModel item, {
    required double width,
  }) {
    final BackpackModel stock = item.stock;
    final String? grade = stock.grade?.image;
    final double gradeHeight = 24.r;

    return Container(
      width: width,
      padding: const EdgeInsets.all(6).r,
      decoration: BoxDecoration(
        color: AppColors.greyBackgroundColor,
        borderRadius: BorderRadius.circular(12).r,
      ),
      child: AspectRatio(
        aspectRatio: SubProductTile.imageAspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppImage(
              name: stock.image,
              fit: BoxFit.contain,
              borderRadius: BorderRadius.circular(6).r,
            ),
            if (grade != null)
              Positioned(
                top: 2.r,
                right: 2.r,
                child: AppImage(
                  name: grade,
                  height: gradeHeight,
                  width: gradeHeight * SubProductGradeTitle.artworkAspectRatio,
                  fit: BoxFit.contain,
                ),
              ),
            Positioned(
              right: 0,
              bottom: 0,
              child: SubProductQuantityBadge(quantity: item.quantity),
            ),
          ],
        ),
      ),
    );
  }

  Widget _coinAmount(BuildContext context, double amount) {
    final double coinSize = 20.r;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppImage(
          name: AppAssets.coins,
          width: coinSize,
          height: coinSize,
          fit: BoxFit.contain,
        ),
        4.widthSpace,
        AppText(
          formatMainProductAmount(amount),
          fontSize: kFont16,
          fontWeight: FontWeight.w600,
        ),
      ],
    );
  }

  /// 申請出貨; while the balance can't cover the shipping fee, greyed out
  /// under a label saying so.
  Widget _submitBar(BuildContext context, CheckoutController controller) {
    final bool canPay = controller.canPayShipping(
      context.watch<AppController>().points,
    );
    final Color primary = context.color.primary;

    return Container(
      padding: EdgeInsets.fromLTRB(
        kHorizontalPadding.r,
        10.r,
        kHorizontalPadding.r,
        MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.wOpacity(0.08),
            blurRadius: 8.r,
            offset: Offset(0, -2.r),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!canPay) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.info_circle_copy, size: 14.r, color: primary),
                4.widthSpace,
                Flexible(
                  child: AppText(
                    context.tr(AppStrings.balanceNotEnoughForShipping),
                    fontSize: kFont12,
                    color: primary,
                  ),
                ),
              ],
            ),
            8.heightSpace,
          ],
          AppButtonWidget(
            text: context.tr(AppStrings.requestShipment),
            radius: 10,
            fontWeight: FontWeight.w600,
            textColor: AppColors.whiteColor,
            padding: const EdgeInsets.symmetric(vertical: 10).r,
            onTap: canPay ? controller.onSubmit : null,
          ),
        ],
      ),
    );
  }
}
