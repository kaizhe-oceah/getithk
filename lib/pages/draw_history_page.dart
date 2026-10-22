// Project imports:
import '../components/default/month_filter_button.dart';
import '../components/default/tab_bar_widget.dart';
import '../components/sub_product/sub_product_parts.dart';
import '../controllers/draw_history_controller.dart';
import '../imports.dart';
import '../models/draw_record_model.dart';
import '../models/product_grade_model.dart';

class DrawHistoryPage extends StatefulWidget {
  const DrawHistoryPage({super.key});

  @override
  State<DrawHistoryPage> createState() => _DrawHistoryPageState();
}

class _DrawHistoryPageState extends State<DrawHistoryPage>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DrawHistoryController(vsync: this),
      child: AppScaffold.basic(
        backgroundColor: AppColors.whiteColor,
        forceOverlayStyle: SystemUiOverlayStyle.dark,
        headerWidgets: [
          AppBarWidget(
            text: context.tr(AppStrings.drawRecord),
            centerTitle: true,
            backgroundColor: AppColors.whiteColor,
            leading: const AppBarBackButton(),
            actions: [
              Consumer<DrawHistoryController>(
                builder: (context, controller, _) => MonthFilterButton(
                  month: controller.month,
                  onTap: controller.onPickMonth,
                ),
              ),
            ],
            bottomWidget: Consumer<DrawHistoryController>(
              builder: (context, controller, _) => TabBarWidget(
                tabController: controller.tabController,
                labels: [
                  context.tr(AppStrings.all),
                  for (final ProductGradeModel grade in controller.grades)
                    grade.name ?? '',
                ],
                tabAlignment: TabAlignment.start,
              ),
            ),
          ),
        ],
        child: Consumer<DrawHistoryController>(
          builder: (context, controller, _) => TabBarView(
            controller: controller.tabController,
            children: [
              for (int i = 0; i < controller.tabController.length; i++)
                _page(context, controller, i),
            ],
          ),
        ),
      ),
    );
  }

  Widget _page(BuildContext context, DrawHistoryController controller, int i) {
    final bool isCurrent = i == controller.tabIndex;

    return SmartRefresherWrapper(
      controller: controller.refreshControllerAt(i),
      onRefresh: controller.onRefresh,
      enablePullUp:
          isCurrent && !controller.isLoading && controller.records.isNotEmpty,
      onLoading: controller.onLoading,
      child: _records(context, controller, i),
    );
  }

  Widget _records(
    BuildContext context,
    DrawHistoryController controller,
    int i,
  ) {
    final EdgeInsets padding = const EdgeInsets.fromLTRB(
      kHorizontalPadding,
      12,
      kHorizontalPadding,
      kHorizontalPadding,
    ).r;
    final bool placeholder =
        i != controller.tabIndex ||
        (controller.isLoading && controller.records.isEmpty);

    if (!placeholder && controller.records.isEmpty) {
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

    final List<DrawRecordModel> records = placeholder
        ? List.generate(6, (_) => DrawRecordModel.placeholder())
        : controller.records;

    return ListView.separated(
      padding: padding,
      itemCount: records.length,
      separatorBuilder: (_, _) => 12.heightSpace,
      itemBuilder: (context, index) => AppSkeletonizer(
        enabled: placeholder,
        child: _recordCard(context, controller, records[index]),
      ),
    );
  }

  Widget _recordCard(
    BuildContext context,
    DrawHistoryController controller,
    DrawRecordModel record,
  ) {
    final ProductGrade? grade = controller.gradeOf(record);
    final double gradeHeight = 18.r;

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
      child: Row(
        children: [
          SizedBox(
            width: 40.r,
            child: AspectRatio(
              aspectRatio: SubProductTile.imageAspectRatio,
              child: AppImage(
                name: record.image,
                fit: BoxFit.contain,
                borderRadius: BorderRadius.circular(4).r,
              ),
            ),
          ),
          kHorizontalPadding.widthSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  record.subProductName ?? '',
                  fontSize: kFont13,
                  fontWeight: FontWeight.w600,
                  maxLines: 2,
                  isOverflow: true,
                ),
                4.heightSpace,
                AppText(
                  formatOrderDate(context, record.createdAt),
                  fontSize: kFont12,
                  color: AppColors.loginHintColor,
                ),
              ],
            ),
          ),
          10.widthSpace,
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (grade != null)
                AppImage(
                  name: grade.image,
                  width: gradeHeight * SubProductGradeTitle.artworkAspectRatio,
                  height: gradeHeight,
                  fit: BoxFit.contain,
                )
              else
                AppText(
                  record.gradeName ?? '',
                  fontSize: kFont12,
                  fontWeight: FontWeight.w600,
                ),
              6.heightSpace,
              AppText(
                '${NumberFormat('#,##0.00').format(record.amount)} pt',
                fontSize: kFont14,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
