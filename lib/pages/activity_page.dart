// Project imports:
import '../components/default/bottom_nav_bar_widget.dart';
import '../components/points_pill.dart';
import '../controllers/activity_controller.dart';
import '../imports.dart';
import '../models/page_banner_model.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  static const double _bannerAspectRatio = 1120 / 496;

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage>
    with AutomaticKeepAliveClientMixin<ActivityPage> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bool isLoggedIn = context.watch<AppController>().user != null;

    return ChangeNotifierProvider(
      create: (_) => ActivityController(),
      child: AppScaffold.basic(
        backgroundColor: AppColors.whiteColor,
        forceOverlayStyle: SystemUiOverlayStyle.dark,
        headerWidgets: [
          AppBarWidget(
            centerTitle: false,
            backgroundColor: AppColors.whiteColor,
            title: AppLogo(height: 28.r),
            actions: [
              if (isLoggedIn)
                Padding(
                  padding: const EdgeInsets.only(right: 8).r,
                  child: const Center(child: PointsPill()),
                ),
            ],
          ),
        ],
        child: Consumer<ActivityController>(
          builder: (context, controller, _) => SmartRefresherWrapper(
            controller: controller.refreshController,
            onRefresh: controller.onRefresh,
            child: _banners(context, controller),
          ),
        ),
      ),
    );
  }

  Widget _banners(BuildContext context, ActivityController controller) {
    final EdgeInsets padding = EdgeInsets.fromLTRB(
      kHorizontalPadding.r,
      12.r,
      kHorizontalPadding.r,
      BottomNavigationWidget.contentBottomInset(context),
    );
    final bool placeholder = controller.isLoading && controller.banners.isEmpty;

    if (!placeholder && controller.banners.isEmpty) {
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

    final List<PageBannerModel> banners = placeholder
        ? List.generate(2, (_) => PageBannerModel.placeholder())
        : controller.banners;

    return ListView.separated(
      padding: padding,
      itemCount: banners.length,
      separatorBuilder: (_, _) => 12.heightSpace,
      itemBuilder: (context, index) => AppSkeletonizer(
        enabled: placeholder,
        child: _bannerCard(
          context,
          controller,
          banners[index],
          isLoading: placeholder,
        ),
      ),
    );
  }

  Widget _bannerCard(
    BuildContext context,
    ActivityController controller,
    PageBannerModel banner, {
    bool isLoading = false,
  }) {
    final VoidCallback? onTap = isLoading
        ? null
        : () => controller.onTapBanner(banner);

    return InkWellWrapper(
      checkLogin: true,
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(12).r,
          boxShadow: [
            BoxShadow(
              color: AppColors.blackColor.wOpacity(0.08),
              blurRadius: 8.r,
              offset: Offset(0, 2.r),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: ActivityPage._bannerAspectRatio,
              child: isLoading
                  ? const Bone()
                  : AppImage(
                      name: banner.image,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.contain,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(10).r,
              child: AppButtonWidget(
                text: context.tr(AppStrings.clickForDetails),
                checkLogin: true,
                radius: 10,
                fontWeight: FontWeight.w600,
                textColor: AppColors.whiteColor,
                onTap: onTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
