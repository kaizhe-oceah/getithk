// Project imports:
import '../components/backpack/backpack_stock_card.dart';
import '../components/main_product/main_product_parts.dart';
import '../components/sub_product/sub_product_parts.dart';
import '../controllers/prize_result_controller.dart';
import '../imports.dart';
import '../models/draw_result_model.dart';

class PrizeResultPage extends StatelessWidget {
  final DrawResultModel result;

  const PrizeResultPage({required this.result, super.key});

  static const double _imageWidth = 56;
  static const double _gradeHeight = 26;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PrizeResultController(result: result),
      child: AppScaffold.basic(
        backgroundColor: AppColors.whiteColor,
        forceOverlayStyle: SystemUiOverlayStyle.dark,
        headerWidgets: [
          AppBarWidget(
            text: context.tr(AppStrings.drawResult),
            backgroundColor: AppColors.whiteColor,
            leading: const AppBarBackButton(),
          ),
        ],
        child: Consumer<PrizeResultController>(
          builder: (context, controller, _) => Column(
            children: [
              Expanded(child: _prizes(context, controller)),
              _actionBar(context, controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _prizes(BuildContext context, PrizeResultController controller) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        kHorizontalPadding.r,
        14.r,
        kHorizontalPadding.r,
        16.r,
      ),
      children: [
        AppText(
          context.tr(AppStrings.selectPrizesToShip),
          fontSize: kFont15,
          fontWeight: FontWeight.w600,
        ),
        4.heightSpace,
        AppText(
          context.tr(AppStrings.selectPrizesToShipHint),
          fontSize: kFont12,
          color: AppColors.textLightColor,
        ),
        if (controller.isTrial) ...[14.heightSpace, _trialNotice(context)],
        for (final List<DrawHistoryModel> group in controller.gradeGroups) ...[
          18.heightSpace,
          _gradeHeader(context, group),
          8.heightSpace,
          for (final DrawHistoryModel prize in group) ...[
            _prizeTile(context, controller, prize),
            8.heightSpace,
          ],
        ],
      ],
    );
  }

  /// 試玩版抽獎結果: nothing from a trial can be shipped or exchanged.
  Widget _trialNotice(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12).r,
      decoration: BoxDecoration(
        color: AppColors.lightPrimaryColor,
        borderRadius: BorderRadius.circular(10).r,
      ),
      child: AppText(
        context.tr(AppStrings.trialResultNotice),
        fontSize: kFont12,
        color: AppColors.secondaryColorSoild,
      ),
    );
  }

  Widget _gradeHeader(BuildContext context, List<DrawHistoryModel> group) {
    return Row(
      children: [
        AppText(
          group.first.subProduct?.grade ?? '',
          fontSize: kFont15,
          fontWeight: FontWeight.w600,
        ),
        10.widthSpace,
        Expanded(
          child: AppText(
            context.tr(AppStrings.prizeCount, args: ['${group.length}']),
            fontSize: kFont12,
            color: AppColors.textLightColor,
          ),
        ),
        _points(context, PrizeResultController.amountOf(group)),
      ],
    );
  }

  /// The checkbox, the card, then its grade, name and worth.
  Widget _prizeTile(
    BuildContext context,
    PrizeResultController controller,
    DrawHistoryModel prize,
  ) {
    final DrawSubProductModel? subProduct = prize.subProduct;
    final ProductGrade? grade = subProduct?.productGrade;
    final bool isDeliveryOnly = subProduct?.isDeliveryOnly ?? false;
    final bool selected = controller.isSelected(prize);
    final double imageWidth = _imageWidth.r;

    return InkWellWrapper(
      onTap: controller.isTrial ? null : () => controller.onToggle(prize),
      child: Container(
        padding: const EdgeInsets.all(12).r,
        decoration: BoxDecoration(
          color: AppColors.greyBackgroundColor,
          borderRadius: BorderRadius.circular(14).r,
          border: Border.all(
            color: selected
                ? context.color.primary
                : AppColors.transparentColor,
          ),
        ),
        child: Row(
          children: [
            BackpackCheckBox(value: selected),
            12.widthSpace,
            Container(
              width: imageWidth,
              padding: const EdgeInsets.all(3).r,
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(6).r,
              ),
              child: AspectRatio(
                aspectRatio: SubProductTile.imageAspectRatio,
                child: AppImage(
                  name: subProduct?.image,
                  fit: BoxFit.contain,
                  borderRadius: BorderRadius.circular(4).r,
                  cacheWidth:
                      (imageWidth * MediaQuery.devicePixelRatioOf(context))
                          .round(),
                ),
              ),
            ),
            12.widthSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (grade != null || isDeliveryOnly) ...[
                    Row(
                      children: [
                        if (grade != null) _grade(context, grade),
                        if (isDeliveryOnly) ...[
                          if (grade != null) 4.widthSpace,
                          const DeliveryOnlyBadge(size: _gradeHeight),
                        ],
                      ],
                    ),
                    2.heightSpace,
                  ],
                  AppText(
                    subProduct?.name ?? '',
                    fontSize: kFont14,
                    fontWeight: FontWeight.w600,
                    maxLines: 2,
                    isOverflow: true,
                  ),
                  4.heightSpace,
                  _points(context, prize.amount, coinSize: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _grade(BuildContext context, ProductGrade grade) {
    final double width =
        _gradeHeight.r * SubProductGradeTitle.artworkAspectRatio;

    return AppImage(
      name: grade.image,
      width: width,
      height: _gradeHeight.r,
      fit: BoxFit.contain,
      cacheWidth: (width * MediaQuery.devicePixelRatioOf(context)).round(),
    );
  }

  /// [amount] pts, after a coin.
  Widget _points(
    BuildContext context,
    double amount, {
    double coinSize = 18,
    double fontSize = kFont14,
  }) {
    final double size = coinSize.r;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppImage(
          name: AppAssets.coins,
          width: size,
          height: size,
          fit: BoxFit.contain,
          cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
        ),
        4.widthSpace,
        AppText(
          formatMainProductAmount(amount),
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ],
    );
  }

  /// The select-alls, then 合計, 申請出貨 and 兌換PTS. For a trial, all of it
  /// disabled, and 會員註冊 above them.
  Widget _actionBar(BuildContext context, PrizeResultController controller) {
    final bool isTrial = controller.isTrial;

    return Container(
      padding: EdgeInsets.fromLTRB(
        kHorizontalPadding.r,
        12.r,
        kHorizontalPadding.r,
        12.r + MediaQuery.paddingOf(context).bottom,
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
          Wrap(
            spacing: 14.r,
            runSpacing: 8.r,
            children: [
              BackpackSelectAll(
                label: AppStrings.selectAll,
                value: controller.isAllSelected,
                enabled: !isTrial,
                onTap: controller.onSelectAll,
              ),
              BackpackSelectAll(
                label: AppStrings.selectAllDeliveryOnly,
                value: controller.isAllDeliveryOnlySelected,
                enabled: !isTrial && controller.deliveryOnly.isNotEmpty,
                onTap: controller.onSelectAllDeliveryOnly,
              ),
              BackpackSelectAll(
                label: AppStrings.selectAllNonDeliveryOnly,
                value: controller.isAllNonDeliveryOnlySelected,
                enabled: !isTrial && controller.nonDeliveryOnly.isNotEmpty,
                onTap: controller.onSelectAllNonDeliveryOnly,
              ),
            ],
          ),
          12.heightSpace,
          if (isTrial) ...[
            AppButtonWidget(
              text: context.tr(AppStrings.memberRegister),
              radius: 10,
              textSize: kFont14,
              fontWeight: FontWeight.w600,
              textColor: AppColors.whiteColor,
              padding: const EdgeInsets.symmetric(vertical: 12).r,
              onTap: controller.onRegister,
            ),
            10.heightSpace,
          ],
          BackpackCheckoutRow(
            amount: controller.selectedAmount,
            hasSelection: controller.selectedPrizes.isNotEmpty,
            canRequestShipment: controller.canRequestShipment,
            canExchange: controller.canExchange,
            onRequestShipment: controller.onRequestShipment,
            onExchange: controller.onExchange,
          ),
        ],
      ),
    );
  }
}
