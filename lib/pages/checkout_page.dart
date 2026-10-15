// Project imports:
import '../components/main_product/main_product_parts.dart';
import '../components/sub_product/sub_product_parts.dart';
import '../controllers/checkout_controller.dart';
import '../imports.dart';
import '../models/backpack_model.dart';
import '../models/shipment_item_model.dart';

class CheckoutPage extends StatelessWidget {
  final List<ShipmentItemModel> items;

  const CheckoutPage({required this.items, super.key});

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
            textSize: kFont16,
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
        padding: const EdgeInsets.all(14).r,
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(14).r,
          border: Border.all(color: AppColors.greyLightColor),
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
                  AppText(
                    context.tr(AppStrings.addShippingAddress),
                    fontSize: kFont12,
                    color: AppColors.loginHintColor,
                  ),
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

  Widget _shippingFee(BuildContext context, CheckoutController controller) {
    final TextStyle style = TextStyle(
      fontSize: kFont12.sp,
      color: AppColors.loginHintColor,
      height: 1.6,
    );
    final List<String> parts = context
        .tr(AppStrings.shippingAgreement)
        .split('{}');

    return Container(
      padding: const EdgeInsets.all(14).r,
      decoration: BoxDecoration(
        color: AppColors.greyBackgroundColor,
        borderRadius: BorderRadius.circular(14).r,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: AppText(
                  context.tr(AppStrings.shippingFee),
                  fontSize: kFont14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              _coinAmount(context, controller.shippingFee),
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
            fontSize: kFont12,
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
            for (final BackpackModel stock in controller.cards)
              _card(context, stock, width: tileWidth),
          ],
        );
      },
    );
  }

  Widget _card(
    BuildContext context,
    BackpackModel stock, {
    required double width,
  }) {
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

  Widget _submitBar(BuildContext context, CheckoutController controller) {
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
      child: AppButtonWidget(
        text: context.tr(AppStrings.requestShipment),
        radius: 10,
        fontWeight: FontWeight.w600,
        textColor: AppColors.whiteColor,

        padding: const EdgeInsets.symmetric(vertical: 10).r,
        onTap: controller.onSubmit,
      ),
    );
  }
}
