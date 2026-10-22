// Project imports:
import '../components/default/month_filter_button.dart';
import '../components/sub_product/sub_product_parts.dart';
import '../controllers/sell_history_controller.dart';
import '../imports.dart';
import '../models/sell_history_model.dart';

class SellHistoryPage extends StatelessWidget {
  const SellHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SellHistoryController(),
      child: AppScaffold.basic(
        backgroundColor: AppColors.whiteColor,
        forceOverlayStyle: SystemUiOverlayStyle.dark,
        headerWidgets: [
          AppBarWidget(
            text: context.tr(AppStrings.salesRecord),
            centerTitle: true,
            backgroundColor: AppColors.whiteColor,
            leading: const AppBarBackButton(),
            actions: [
              Consumer<SellHistoryController>(
                builder: (context, controller, _) => MonthFilterButton(
                  month: controller.month,
                  onTap: controller.onPickMonth,
                ),
              ),
            ],
          ),
        ],
        child: Consumer<SellHistoryController>(
          builder: (context, controller, _) => SmartRefresherWrapper(
            controller: controller.refreshController,
            onRefresh: controller.onRefresh,
            enablePullUp: !controller.isLoading && controller.orders.isNotEmpty,
            onLoading: controller.onLoading,
            child: _orders(context, controller),
          ),
        ),
      ),
    );
  }

  Widget _orders(BuildContext context, SellHistoryController controller) {
    final EdgeInsets padding = EdgeInsets.fromLTRB(
      kHorizontalPadding.r,
      12.r,
      kHorizontalPadding.r,
      kHorizontalPadding,
    );
    final bool placeholder = controller.isLoading && controller.orders.isEmpty;

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

    final List<SellHistoryModel> orders = placeholder
        ? List.generate(3, (_) => SellHistoryModel.placeholder())
        : controller.orders;

    return ListView.separated(
      padding: padding,
      itemCount: orders.length,
      separatorBuilder: (_, _) => 12.heightSpace,
      itemBuilder: (context, index) => AppSkeletonizer(
        enabled: placeholder,
        child: _orderCard(context, orders[index]),
      ),
    );
  }

  Widget _orderCard(BuildContext context, SellHistoryModel order) {
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
                  formatOrderDate(context, order.soldAt),
                  fontSize: kFont12,
                  color: AppColors.loginHintColor,
                ),
              ),
              8.widthSpace,
              AppText(
                '${context.tr(AppStrings.prizeCount, args: ['${order.totalItems}'])} : ',
                fontSize: kFont12,
              ),
              AppText(
                '${NumberFormat('#,##0.00').format(order.totalAmount)} pt',
                fontSize: kFont12,
                fontWeight: FontWeight.w700,
                color: context.color.primary,
              ),
            ],
          ),
          12.heightSpace,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (int i, SellHistoryItemModel item)
                    in order.products.indexed) ...[
                  if (i > 0) 14.widthSpace,
                  _soldCard(item),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _soldCard(SellHistoryItemModel item) {
    final double width = 80.r;
    final double gradeHeight = 15.r;
    final double overlap = 6.r;
    final ProductGrade? grade = item.grade;

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(top: gradeHeight - overlap),
                child: SubProductTile(
                  product: item.toSubProduct()..quantity = null,
                  width: width,
                ),
              ),
              if (grade != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: AppImage(
                    name: grade.image,
                    width:
                        gradeHeight * SubProductGradeTitle.artworkAspectRatio,
                    height: gradeHeight,
                    fit: BoxFit.contain,
                  ),
                ),
            ],
          ),
          Transform.translate(
            offset: Offset(0, -overlap),
            child: SubProductQuantityBadge(quantity: item.quantity),
          ),
        ],
      ),
    );
  }
}
