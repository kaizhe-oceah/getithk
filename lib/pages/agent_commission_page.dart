// Project imports:
import '../components/invite/invite_parts.dart';
import '../controllers/agent_commission_controller.dart';
import '../imports.dart';
import '../models/topup_commission_model.dart';

class AgentCommissionPage extends StatelessWidget {
  const AgentCommissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AgentCommissionController(),
      child: AppScaffold.basic(
        backgroundColor: AppColors.whiteColor,
        forceOverlayStyle: SystemUiOverlayStyle.dark,
        headerWidgets: [
          AppBarWidget(
            text: context.tr(AppStrings.agentCommission),
            backgroundColor: AppColors.whiteColor,
            leading: const AppBarBackButton(),
          ),
        ],
        child: Consumer<AgentCommissionController>(
          builder: (context, controller, _) => _content(context, controller),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, AgentCommissionController controller) {
    final TopupCommissionSummaryModel summary =
        controller.summary ??
        (controller.isLoading
            ? TopupCommissionSummaryModel.placeholder()
            : TopupCommissionSummaryModel.fromJson({}));

    return SmartRefresherWrapper(
      controller: controller.refreshController,
      onRefresh: controller.onRefresh,
      enablePullUp: !controller.isLoading && controller.commissions.isNotEmpty,
      onLoading: controller.onLoading,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          kHorizontalPadding.r,
          12.r,
          kHorizontalPadding.r,
          kHorizontalPadding.r,
        ),
        children: [
          const InviteHeader(
            title: AppStrings.commissionTitle,
            chip: AppStrings.commissionChip,
            description: AppStrings.commissionDescription,
            steps: [
              (Iconsax.link_21_copy, AppStrings.commissionStepShare),
              (Iconsax.user_add_copy, AppStrings.inviteStepRegister),
              (Iconsax.coin_copy, AppStrings.commissionStepTopUp),
              (Iconsax.gift_copy, AppStrings.commissionStepReward),
            ],
          ),
          12.heightSpace,
          InviteStats(
            loading: controller.isLoading,
            stats: [
              (
                context.tr(AppStrings.successfulInvites),
                context.tr(
                  AppStrings.peopleCount,
                  args: ['${summary.totalInvitedUsers}'],
                ),
              ),
              (
                context.tr(AppStrings.totalTopUpCount),
                context.tr(
                  AppStrings.timesCount,
                  args: ['${summary.totalTopupCount}'],
                ),
              ),
              (
                context.tr(AppStrings.totalCommission),
                '${_amount(summary.totalAmount)} pt',
              ),
            ],
          ),
          12.heightSpace,
          const InviteCodeCard(),
          20.heightSpace,
          AppText(
            context.tr(AppStrings.commissionRecords),
            fontSize: kFont15,
            fontWeight: FontWeight.w700,
          ),
          10.heightSpace,
          _commissions(context, controller),
        ],
      ),
    );
  }

  static const int _playerFlex = 4;
  static const int _topUpFlex = 4;
  static const int _earnedFlex = 3;

  Widget _commissions(
    BuildContext context,
    AgentCommissionController controller,
  ) {
    final bool placeholder =
        controller.isLoading && controller.commissions.isEmpty;
    final List<TopupCommissionModel> commissions = placeholder
        ? List.generate(3, (_) => TopupCommissionModel.placeholder())
        : controller.commissions;
    final String currency =
        context.read<AppController>().user?.currencyCode ?? 'HKD';

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: inviteCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: context.color.primary,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10).r,
            child: Row(
              children: [
                _headerCell(
                  context.tr(AppStrings.playerDateTime),
                  _playerFlex,
                  TextAlign.start,
                ),
                _headerCell(
                  context.tr(AppStrings.topUpAmountRate),
                  _topUpFlex,
                  TextAlign.center,
                ),
                _headerCell(
                  context.tr(AppStrings.commissionEarned),
                  _earnedFlex,
                  TextAlign.end,
                ),
              ],
            ),
          ),
          if (commissions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24).r,
              child: const NoDataWidget(),
            ),
          for (int i = 0; i < commissions.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.greyLight2Color,
              ),
            AppSkeletonizer(
              enabled: placeholder,
              child: _commissionRow(context, commissions[i], currency),
            ),
          ],
        ],
      ),
    );
  }

  Widget _headerCell(String text, int flex, TextAlign align) {
    return Expanded(
      flex: flex,
      child: AppText(
        text,
        fontSize: kFont12,
        fontWeight: FontWeight.w600,
        color: AppColors.whiteColor,
        textAlign: align,
      ),
    );
  }

  Widget _commissionRow(
    BuildContext context,
    TopupCommissionModel commission,
    String currency,
  ) {
    final Color primary = context.color.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12).r,
      child: Row(
        children: [
          Expanded(
            flex: _playerFlex,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  commission.name ?? '',
                  fontSize: kFont13,
                  fontWeight: FontWeight.w600,
                  maxLines: 1,
                  isOverflow: true,
                ),
                2.heightSpace,
                AppText(
                  formatOrderDate(context, commission.date),
                  fontSize: kFont11,
                  color: AppColors.loginHintColor,
                ),
              ],
            ),
          ),
          Expanded(
            flex: _topUpFlex,
            child: Column(
              children: [
                AppText(
                  '$currency ${_amount(commission.topupAmount)}',
                  fontSize: kFont13,
                  fontWeight: FontWeight.w700,
                  textAlign: TextAlign.center,
                ),
                2.heightSpace,
                AppText(
                  'x ${NumberFormat('0.0#').format(commission.commissionRate)}%',
                  fontSize: kFont11,
                  color: AppColors.loginHintColor,
                ),
              ],
            ),
          ),
          Expanded(
            flex: _earnedFlex,
            child: Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ).r,
                  decoration: BoxDecoration(
                    color: primary.wOpacity(0.08),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: AppText(
                    '+${_amount(commission.amount)} pt',
                    fontSize: kFont12,
                    fontWeight: FontWeight.w700,
                    color: primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _amount(double value) => NumberFormat('#,##0.00').format(value);
}
