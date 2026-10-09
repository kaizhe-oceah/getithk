// Project imports:
import '../controllers/topup_controller.dart';
import '../imports.dart';
import '../models/payment_method_model.dart';
import '../models/topup_bonus_model.dart';

class TopupPage extends StatelessWidget {
  const TopupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TopupController(),
      child: AppScaffold.basic(
        backgroundColor: AppColors.whiteColor,
        forceOverlayStyle: SystemUiOverlayStyle.dark,
        headerWidgets: [
          AppBarWidget(
            text: context.tr(AppStrings.topUp),
            textSize: kFont16,
            backgroundColor: AppColors.whiteColor,
            leading: const AppBarBackButton(),
          ),
        ],
        child: Consumer<TopupController>(
          builder: (context, controller, _) => _content(context, controller),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, TopupController controller) {
    final bool skeleton = controller.isLoading && controller.bonuses.isEmpty;
    final List<TopupBonusModel> bonuses = skeleton
        ? List.generate(3, (_) => TopupBonusModel.placeholder())
        : controller.bonuses;

    return SmartRefresherWrapper(
      controller: controller.refreshController,
      onRefresh: controller.onRefresh,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          kHorizontalPadding.r,
          12.r,
          kHorizontalPadding.r,
          20.r + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          _balanceCard(context),
          14.heightSpace,
          AppSkeletonizer(
            enabled: controller.isLoading,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _paymentMethods(context, controller, skeleton: skeleton),
                18.heightSpace,
                Skeleton.keep(
                  child: AppText(
                    context.tr(AppStrings.selectTopUpAmount),
                    fontSize: kFont15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.loginTextColor,
                  ),
                ),
                10.heightSpace,
                for (final TopupBonusModel bonus in bonuses) ...[
                  _bonusCard(context, controller, bonus),
                  12.heightSpace,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 我的餘額 0.00 PTS on primary, the wallet in a soft circle on the right.
  Widget _balanceCard(BuildContext context) {
    final double points = context.watch<AppController>().points;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.color.primary,
        borderRadius: BorderRadius.circular(16).r,
      ),
      child: Stack(
        children: [
          // the circle runs off the card's right edge, clipped by it
          Positioned(
            right: -28.r,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                width: 132.r,
                height: 132.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.whiteColor.wOpacity(0.16),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: EdgeInsets.only(right: 16.r),
                  child: Image.asset(
                    AppAssets.topUp,
                    width: 84.r,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(18.r, 22.r, 120.r, 22.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  context.tr(AppStrings.myBalance),
                  fontSize: kFont13,
                  color: AppColors.whiteColor.wOpacity(0.9),
                ),
                6.heightSpace,
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: AppText(
                    '${NumberFormat('#,##0.00').format(points)} PTS',
                    fontSize: kFont26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.whiteColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentMethods(
    BuildContext context,
    TopupController controller, {
    required bool skeleton,
  }) {
    final List<PaymentMethodModel> methods = controller.paymentMethods;

    if (methods.isEmpty) {
      return skeleton
          ? Bone(height: 52.r, borderRadius: BorderRadius.circular(12).r)
          : const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomDropdownButton<PaymentMethodModel>(
          // re-reads the pick when a logo changes it
          key: ValueKey(controller.paymentMethod?.gateway),
          dataList: methods,
          initItem: controller.paymentMethod,
          width: double.infinity,
          radius: 12,
          border: Border.all(color: AppColors.greyLight2Color),
          boxShadow: _cardShadow,
          hint: context.tr(AppStrings.selectPaymentMethod),
          onChanged: controller.onSelectPaymentMethod,
          dropdownItemBuilder: (context, index) => DropdownItem(
            value: methods[index],
            height: 48.r,
            child: _methodLabel(methods[index]),
          ),
          selectedItemBuilder: (context, index) => DropdownMenuItem(
            value: methods[index],
            child: _methodLabel(methods[index]),
          ),
        ),
        10.heightSpace,
        Wrap(
          spacing: 8.r,
          runSpacing: 8.r,
          children: [
            for (final PaymentMethodModel method in methods)
              _methodLogo(context, controller, method),
          ],
        ),
      ],
    );
  }

  /// A method's logo and name, in the dropdown.
  Widget _methodLabel(PaymentMethodModel method) {
    return Row(
      children: [
        AppImage(
          name: method.icon,
          width: 30.r,
          height: 20.r,
          fit: BoxFit.contain,
        ),
        12.widthSpace,
        Expanded(
          child: AppText(
            method.name ?? '',
            fontSize: kFont14,
            fontWeight: FontWeight.w500,
            color: AppColors.loginTextColor,
            isOverflow: true,
          ),
        ),
      ],
    );
  }

  Widget _methodLogo(
    BuildContext context,
    TopupController controller,
    PaymentMethodModel method,
  ) {
    final bool selected = method == controller.paymentMethod;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6).r,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(6).r,
        border: Border.all(color: AppColors.greyLight2Color),
      ),
      child: AppImage(
        name: method.icon,
        width: 30.r,
        height: 18.r,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _bonusCard(
    BuildContext context,
    TopupController controller,
    TopupBonusModel bonus,
  ) {
    final Color primary = context.color.primary;
    final double coinSize = 48.r;
    final String currency =
        context.read<AppController>().user?.currencyCode ?? 'HKD';

    return Container(
      padding: const EdgeInsets.all(14).r,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12).r,
        border: Border.all(color: AppColors.greyLight2Color),
        boxShadow: _cardShadow,
      ),
      child: Row(
        children: [
          Image.asset(
            AppAssets.coins,
            width: coinSize,
            height: coinSize,
            cacheWidth: (coinSize * MediaQuery.devicePixelRatioOf(context))
                .round(),
          ),
          14.widthSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  '${_pts(bonus.creditedAmount)} pts',
                  fontSize: kFont17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.loginTextColor,
                ),
                4.heightSpace,
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ).r,
                  decoration: BoxDecoration(
                    color: primary.wOpacity(0.08),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: AppText(
                    context.tr(
                      AppStrings.bonusRate,
                      args: [NumberFormat('#,##0.##').format(bonus.rate)],
                    ),
                    fontSize: kFont10,
                    fontWeight: FontWeight.w600,
                    color: primary,
                  ),
                ),
                6.heightSpace,
                AppText(
                  '$currency ${NumberFormat('#,##0.##').format(bonus.amount)}',
                  fontSize: kFont12,
                  color: AppColors.textLightColor,
                ),
                2.heightSpace,
                AppText(
                  context.tr(
                    AppStrings.extraReward,
                    args: [_pts(bonus.bonusAmount)],
                  ),
                  fontSize: kFont12,
                  color: AppColors.textLightColor,
                ),
              ],
            ),
          ),
          10.widthSpace,
          AppButtonWidget(
            text: context.tr(AppStrings.topUpNow),
            isMinWidth: true,
            radius: 8,
            textSize: kFont12,
            textColor: AppColors.whiteColor,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8).r,
            onTap: () => controller.onTopUp(bonus),
          ),
        ],
      ),
    );
  }

  String _pts(double value) => NumberFormat('#,##0.00').format(value);

  List<BoxShadow> get _cardShadow => [
    BoxShadow(
      color: AppColors.blackColor.wOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
}
