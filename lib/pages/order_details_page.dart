// Project imports:
import '../components/main_product/main_product_parts.dart';
import '../components/shipping_address_card.dart';
import '../controllers/order_details_controller.dart';
import '../imports.dart';
import '../models/shipping_order_detail_model.dart';
import '../models/shipping_order_model.dart';

class OrderDetailsPage extends StatelessWidget {
  final int shippingId;

  const OrderDetailsPage({required this.shippingId, super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrderDetailsController(shippingId: shippingId),
      child: AppScaffold.basic(
        backgroundColor: AppColors.whiteColor,
        forceOverlayStyle: SystemUiOverlayStyle.dark,
        headerWidgets: [
          AppBarWidget(
            text: context.tr(AppStrings.orderDetails),
            centerTitle: true,
            backgroundColor: AppColors.whiteColor,
            leading: const AppBarBackButton(),
          ),
        ],
        child: Consumer<OrderDetailsController>(
          builder: (context, controller, _) => _content(context, controller),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, OrderDetailsController controller) {
    final bool skeleton = controller.isLoading && controller.order == null;
    final ShippingOrderDetailModel? order = skeleton
        ? ShippingOrderDetailModel.placeholder()
        : controller.order;

    return SmartRefresherWrapper(
      controller: controller.refreshController,
      onRefresh: controller.onRefresh,
      child: order == null
          ? const CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: NoDataWidget()),
                ),
              ],
            )
          : ListView(
              padding: EdgeInsets.fromLTRB(
                kHorizontalPadding.r,
                12.r,
                kHorizontalPadding.r,
                20.r + MediaQuery.paddingOf(context).bottom,
              ),
              children: [
                AppSkeletonizer(
                  enabled: skeleton,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (order.address != null) ...[
                        ShippingAddressCard(address: order.address),
                        12.heightSpace,
                      ],
                      _items(context, order),
                      12.heightSpace,
                      _info(context, order),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _items(BuildContext context, ShippingOrderDetailModel order) {
    return Container(
      padding: const EdgeInsets.all(14).r,
      decoration: _cardDecoration,
      child: Column(
        children: [
          for (final (int index, ShippingOrderItemModel item)
              in order.items.indexed) ...[
            if (index > 0) 12.heightSpace,
            _item(context, item),
          ],
        ],
      ),
    );
  }

  Widget _item(BuildContext context, ShippingOrderItemModel item) {
    final double imageSize = 52.r;

    return Row(
      children: [
        Container(
          width: imageSize,
          height: imageSize,
          padding: const EdgeInsets.all(4).r,
          decoration: BoxDecoration(
            color: AppColors.greyBackgroundColor,
            borderRadius: BorderRadius.circular(8).r,
          ),
          child: AppImage(
            name: item.image,
            fit: BoxFit.contain,
            borderRadius: BorderRadius.circular(4).r,
          ),
        ),
        12.widthSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                item.subProductName ?? '',
                fontSize: kFont14,
                fontWeight: FontWeight.w600,
                maxLines: 2,
                isOverflow: true,
              ),
              4.heightSpace,
              AppText(
                _pts(item.amount),
                fontSize: kFont14,
                fontWeight: FontWeight.w700,
                color: context.color.primary,
              ),
            ],
          ),
        ),
        8.widthSpace,
        AppText(
          'x${item.quantity}',
          fontSize: kFont14,
          fontWeight: FontWeight.w600,
          fontStyle: FontStyle.italic,
        ),
      ],
    );
  }

  Widget _info(BuildContext context, ShippingOrderDetailModel order) {
    final String trackingNo = order.trackingNo ?? '';

    return Container(
      padding: const EdgeInsets.all(14).r,
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(
            context.tr(AppStrings.orderInfo),
            fontSize: kFont14,
            fontWeight: FontWeight.w600,
          ),
          _infoRow(
            context,
            AppStrings.orderStatus,
            order.statusName ?? '',
            color: context.color.primary,
          ),
          _infoRow(context, AppStrings.freight, _pts(order.shippingFee)),
          _infoRow(context, AppStrings.selectedTotal, _pts(order.totalAmount)),
          _infoRow(context, AppStrings.orderNo, order.orderId ?? ''),
          if (trackingNo.isNotEmpty)
            _infoRow(context, AppStrings.trackingNo, trackingNo),
          _infoRow(
            context,
            AppStrings.orderTime,
            formatOrderDate(context, order.createdAt),
          ),
          if ((order.cancelReason ?? '').isNotEmpty)
            _infoRow(context, AppStrings.cancelReason, order.cancelReason!),
          if ((order.remark ?? '').isNotEmpty)
            _infoRow(context, AppStrings.remark, order.remark!),
        ],
      ),
    );
  }

  Widget _infoRow(
    BuildContext context,
    String label,
    String value, {
    Color? color,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: 12.r),
      child: Row(
        children: [
          AppText(
            context.tr(label),
            fontSize: kFont13,
            color: AppColors.textLightColor,
          ),
          12.widthSpace,
          Expanded(
            child: AppText(
              value,
              fontSize: kFont13,
              fontWeight: FontWeight.w500,
              color: color,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _pts(double amount) => '${formatMainProductAmount(amount)} PT';

  BoxDecoration get _cardDecoration => BoxDecoration(
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
  );
}
