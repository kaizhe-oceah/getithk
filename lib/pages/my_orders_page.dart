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
      // nothing to load more of: just the no data widget, no footer
      enablePullUp:
          isCurrent && !controller.isLoading && controller.orders.isNotEmpty,
      onLoading: controller.onLoading,
      showNoDataText: true,
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
      20.r + MediaQuery.paddingOf(context).bottom,
    );
    final bool placeholder =
        tab != controller.tab ||
        (controller.isLoading && controller.orders.isEmpty);

    // centred, still pulling down to refresh
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
        ? List.generate(3, (_) => ShippingOrderModel.placeholder())
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

  /// When and its status; while it waits to ship, the note on how long
  /// that takes; its cards; the shipping fee and total; then 取消 (while it
  /// waits) and 查看.
  Widget _orderCard(
    BuildContext context,
    MyOrdersController controller,
    ShippingOrderModel order,
  ) {
    final bool isToShip = order.status == ShippingStatus.toShip;
    // done with (completed, cancelled): grey, not primary
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
                  _date(context, order.createdAt),
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

  /// [value] in the phone's time, e.g. "10月16日, 02:08:02".
  String _date(BuildContext context, DateTime? value) {
    if (value == null) return '';

    final DateTime date = value.toLocal();
    final String locale = context.locale.toString();
    return '${DateFormat.MMMd(locale).format(date)}, '
        '${DateFormat.Hms(locale).format(date)}';
  }

  /// The card's picture on grey, its name and price, then how many.
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
                '${formatMainProductAmount(item.amount)} PTS',
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

  /// "運費 50 PTS": the label in grey, the amount in primary.
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
          '${formatMainProductAmount(amount)} PTS',
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
