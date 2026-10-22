// Project imports:
import '../components/default/tab_bar_widget.dart';
import '../components/main_product/main_product_parts.dart';
import '../controllers/my_orders_controller.dart';
import '../imports.dart';
import '../models/shipping_order_model.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyOrdersController(vsync: this),
      child: AppScaffold.basic(
        backgroundColor: AppColors.whiteColor,
        forceOverlayStyle: SystemUiOverlayStyle.dark,
        headerWidgets: [
          AppBarWidget(
            text: context.tr(AppStrings.myOrders),
            centerTitle: true,
            backgroundColor: AppColors.whiteColor,
            leading: const AppBarBackButton(),
            bottomWidget: Consumer<MyOrdersController>(
              builder: (context, controller, _) => TabBarWidget(
                tabController: controller.tabController,
                labels: [
                  for (final OrderTab tab in OrderTab.values)
                    context.tr(tab.label),
                ],
                tabAlignment: TabAlignment.start,
              ),
            ),
          ),
        ],
        child: Consumer<MyOrdersController>(
          builder: (context, controller, _) => TabBarView(
            controller: controller.tabController,
            children: [
              for (final OrderTab tab in OrderTab.values)
                _page(context, controller, tab),
            ],
          ),
        ),
      ),
    );
  }

  Widget _page(
    BuildContext context,
    MyOrdersController controller,
    OrderTab tab,
  ) {
    final bool isCurrent = tab == controller.tab;

    return SmartRefresherWrapper(
      controller: controller.refreshControllers[tab]!,
      onRefresh: controller.onRefresh,
      enablePullUp:
          isCurrent && !controller.isLoading && controller.orders.isNotEmpty,
      onLoading: controller.onLoading,
      child: _orders(context, controller, tab),
    );
  }

  Widget _orders(
    BuildContext context,
    MyOrdersController controller,
    OrderTab tab,
  ) {
    final EdgeInsets padding = EdgeInsets.fromLTRB(
      kHorizontalPadding.r,
      12.r,
      kHorizontalPadding.r,
      kHorizontalPadding,
    );
    final bool placeholder =
        tab != controller.tab ||
        (controller.isLoading && controller.orders.isEmpty);

    if (!placeholder && controller.orders.isEmpty) {
      return CustomScrollView(
        slivers: [
          SliverPadding(
            padding: padding,
            sliver: const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: NoDataWidget()),
            ),
          ),
        ],
      );
    }

    final List<ShippingOrderModel> orders = placeholder
        ? List.generate(2, (_) => ShippingOrderModel.placeholder())
        : controller.orders;

    return ListView.separated(
      padding: padding,
      itemCount: orders.length,
      separatorBuilder: (_, _) => 12.heightSpace,
      itemBuilder: (context, index) => AppSkeletonizer(
        enabled: placeholder,
        child: _orderCard(context, controller, orders[index]),
      ),
    );
  }

  Widget _orderCard(
    BuildContext context,
    MyOrdersController controller,
    ShippingOrderModel order,
  ) {
    final bool isToShip = order.status == ShippingStatus.toShip;
    final bool isClosed =
        order.status == ShippingStatus.completed ||
        order.status == ShippingStatus.cancelled;

    return Container(
      padding: const EdgeInsets.all(14).r,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: AppText(
                  formatOrderDate(context, order.createdAt),
                  fontSize: kFont12,
                  color: AppColors.loginHintColor,
                ),
              ),
              AppText(
                order.statusName ?? '',
                fontSize: kFont12,
                fontWeight: FontWeight.w600,
                color: isClosed
                    ? AppColors.loginHintColor
                    : context.color.primary,
              ),
            ],
          ),
          if (isToShip) ...[
            10.heightSpace,
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ).r,
              decoration: BoxDecoration(
                color: AppColors.greyBackgroundColor,
                borderRadius: BorderRadius.circular(8).r,
              ),
              child: AppText(
                context.tr(AppStrings.orderPendingNote),
                fontSize: kFont12,
                color: AppColors.textLightColor,
              ),
            ),
          ],
          for (final ShippingOrderItemModel item in order.items) ...[
            12.heightSpace,
            _item(context, item),
          ],
          12.heightSpace,
          Row(
            children: [
              _amount(context, AppStrings.freight, order.shippingFee),
              const Spacer(),
              _amount(context, AppStrings.selectedTotal, order.totalAmount),
            ],
          ),
          10.heightSpace,
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.greyLight2Color,
          ),
          10.heightSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isToShip) ...[
                _actionButton(
                  context.tr(AppStrings.cancel),
                  onTap: () => controller.onCancel(order),
                ),
                8.widthSpace,
              ],
              _actionButton(
                context.tr(AppStrings.view),
                onTap: () => controller.onView(order),
              ),
            ],
          ),
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
                '${formatMainProductAmount(item.amount)} PT',
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

  Widget _amount(BuildContext context, String label, double amount) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          context.tr(label),
          fontSize: kFont12,
          color: AppColors.textLightColor,
        ),
        4.widthSpace,
        AppText(
          '${formatMainProductAmount(amount)} PT',
          fontSize: kFont12,
          fontWeight: FontWeight.w600,
          color: context.color.primary,
        ),
      ],
    );
  }

  Widget _actionButton(String text, {required VoidCallback onTap}) {
    return AppButtonWidget(
      text: text,
      isMinWidth: true,
      radius: 10,
      textSize: kFont12,
      fontWeight: FontWeight.w500,
      buttonColor: AppColors.greyBackgroundColor,
      textColor: AppColors.loginTextColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8).r,
      onTap: onTap,
    );
  }
}
