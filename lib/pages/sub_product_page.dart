// Project imports:
import '../components/main_product/main_product_parts.dart';
import '../components/points_pill.dart';
import '../components/sub_product/sub_product_parts.dart';
import '../controllers/sub_product_controller.dart';
import '../imports.dart';
import '../models/main_product_model.dart';
import '../models/sub_product_model.dart';

class SubProductPage extends StatelessWidget {
  final MainProductModel product;

  const SubProductPage({required this.product, super.key});

  static double get _sidePadding => 8.r;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SubProductController(product: product),
      child: AppScaffold.basic(
        backgroundColor: AppColors.whiteColor,
        forceOverlayStyle: SystemUiOverlayStyle.dark,
        headerWidgets: [_appBar(context)],
        child: Consumer<SubProductController>(
          builder: (context, controller, _) => _content(context, controller),
        ),
      ),
    );
  }

  Widget _appBar(BuildContext context) {
    final bool isLoggedIn = context.watch<AppController>().user != null;

    return AppBarWidget(
      backgroundColor: AppColors.whiteColor,
      leading: const AppBarBackButton(),
      actions: [
        if (isLoggedIn)
          Padding(
            padding: const EdgeInsets.only(right: 8).r,
            child: const Center(child: PointsPill()),
          ),
      ],
    );
  }

  Widget _content(BuildContext context, SubProductController controller) {
    final MainProductModel product = controller.product;
    final Widget? about = _about(product);

    return Column(
      children: [
        Expanded(
          child: SmartRefresherWrapper(
            controller: controller.refreshController,
            onRefresh: controller.onRefresh,
            child: ListView(
              padding: EdgeInsets.only(top: 0.r, bottom: 20.r),
              children: [
                AppSkeletonizer(
                  enabled: controller.isLoading,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      MainProductImage(image: product.image),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: _sidePadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            10.heightSpace,
                            if (about != null) ...[about, 10.heightSpace],
                            _tagsAndPrice(product),
                            if (product.hasTopupUnlock) ...[
                              10.heightSpace,
                              MainProductTopupUnlock(product: product),
                            ],
                            20.heightSpace,
                            _prizes(controller),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        AppSkeletonizer(
          enabled: controller.isLoading,
          child: _drawBar(context, controller),
        ),
      ],
    );
  }

  Widget? _about(MainProductModel product) {
    final String name = product.name?.trim() ?? '';
    final String description = (product.description ?? '')
        .replaceAll('\r\n', '\n')
        .trim();
    if (name.isEmpty && description.isEmpty) return null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (name.isNotEmpty)
          AppText(
            name,
            fontSize: kFont14,
            fontWeight: FontWeight.w700,
            color: AppColors.loginTextColor,
          ),
        if (name.isNotEmpty && description.isNotEmpty) 4.heightSpace,
        if (description.isNotEmpty)
          AppText(
            description,
            fontSize: kFont11,
            color: AppColors.textLightColor,
          ),
      ],
    );
  }

  Widget _tagsAndPrice(MainProductModel product) {
    return MainProductTags(tags: product.tags);
  }

  Widget _prizes(SubProductController controller) {
    final SubProductModel? comb = controller.combProduct;
    final bool placeholder =
        controller.isLoading && controller.subProducts.isEmpty && comb == null;

    final List<List<SubProductModel>> groups = placeholder
        ? [List.generate(2, (_) => SubProductModel.placeholder())]
        : comb != null
        ? [
            [comb],
          ]
        : controller.gradeGroups;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double spacing = 10.r;
        final double tileWidth = (constraints.maxWidth - spacing) / 2;

        return Column(
          children: [
            for (final (int index, List<SubProductModel> group)
                in groups.indexed) ...[
              if (index > 0)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.r),
                  child: const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.greyLightColor,
                  ),
                ),
              SubProductGradeTitle(
                gradeId: group.first.gradeId,
                name: group.first.gradeName,
              ),
              10.heightSpace,
              Wrap(
                alignment: WrapAlignment.center,
                spacing: spacing,
                runSpacing: 14.r,
                children: [
                  for (final SubProductModel item in group)
                    SubProductTile(product: item, width: tileWidth),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _drawBar(BuildContext context, SubProductController controller) {
    final MainProductModel product = controller.product;

    return Container(
      padding: EdgeInsets.fromLTRB(
        _sidePadding,
        8.r,
        _sidePadding,
        8.r + MediaQuery.paddingOf(context).bottom,
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
          // the price, and how many are left unless the product hides it
          if (product.isShowQuantity)
            MainProductPriceAndStock(product: product)
          else
            MainProductPrice(product: product),
          10.heightSpace,
          MainProductDrawButtons(product: product, onDraw: controller.onDraw),
        ],
      ),
    );
  }
}
