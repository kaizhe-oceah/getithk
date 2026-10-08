// Project imports:
import '../controllers/invite_friends_controller.dart';
import '../imports.dart';
import '../models/invite_point_model.dart';

class InviteFriendsPage extends StatelessWidget {
  const InviteFriendsPage({super.key});

  static const Color _headerTopColor = Color(0xFFFFE3E7);
  static const Color _headerBottomColor = Color(0xFFFFF6F7);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InviteFriendsController(),
      child: AppScaffold.basic(
        backgroundColor: AppColors.whiteColor,
        forceOverlayStyle: SystemUiOverlayStyle.dark,
        headerWidgets: [
          AppBarWidget(
            text: context.tr(AppStrings.inviteFriends),
            textSize: kFont16,
            backgroundColor: AppColors.whiteColor,
            leading: const AppBarBackButton(),
          ),
        ],
        child: Consumer<InviteFriendsController>(
          builder: (context, controller, _) => _content(context, controller),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, InviteFriendsController controller) {
    final InvitePointModel invitePoint =
        controller.invitePoint ??
        (controller.isLoading
            ? InvitePointModel.placeholder()
            : InvitePointModel.fromJson({}));

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
          _header(context),
          12.heightSpace,
          // only the API's numbers and tiers show a skeleton while loading;
          // the fixed text and images show at once
          _stats(context, invitePoint, loading: controller.isLoading),
          12.heightSpace,
          _inviteCode(context, controller),
          12.heightSpace,
          _rewards(
            context,
            controller,
            invitePoint,
            loading: controller.isLoading,
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 10, 12).r,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_headerTopColor, _headerBottomColor],
        ),
        borderRadius: BorderRadius.circular(16).r,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      context.tr(AppStrings.inviteTitle),
                      fontSize: kFont18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.loginTextColor,
                    ),
                    8.heightSpace,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ).r,
                      decoration: BoxDecoration(
                        color: AppColors.blackColor,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: AppText(
                        context.tr(AppStrings.inviteFreePoints),
                        fontSize: kFont11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.whiteColor,
                      ),
                    ),
                    8.heightSpace,
                    AppText(
                      context.tr(AppStrings.inviteDescription),
                      fontSize: kFont11,
                      color: AppColors.textLightColor,
                      height: 1.5,
                    ),
                  ],
                ),
              ),
              Image.asset(AppAssets.prize, width: 104.r, fit: BoxFit.contain),
            ],
          ),
          12.heightSpace,
          _steps(context),
        ],
      ),
    );
  }

  Widget _steps(BuildContext context) {
    final Color primary = context.color.primary;
    final double circleSize = 36.r;
    final List<(IconData, String)> steps = [
      (Iconsax.link_21_copy, AppStrings.inviteStepShare),
      (Iconsax.user_add_copy, AppStrings.inviteStepRegister),
      (Iconsax.coin_copy, AppStrings.inviteStepTopUp),
      (Iconsax.gift_copy, AppStrings.inviteStepPoints),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12).r,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12).r,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            if (i > 0)
              SizedBox(
                height: circleSize,
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 18.r,
                  color: primary,
                ),
              ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: BoxDecoration(
                      color: primary.wOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(steps[i].$1, size: 18.r, color: primary),
                  ),
                  6.heightSpace,
                  AppText(
                    context.tr(steps[i].$2),
                    fontSize: kFont11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.blackColor,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _stats(
    BuildContext context,
    InvitePointModel invitePoint, {
    required bool loading,
  }) {
    Widget divider() => Container(
      width: 1,
      height: 40.r,
      color: AppColors.whiteColor.wOpacity(0.8),
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16).r,
      decoration: BoxDecoration(
        color: context.color.primary,
        borderRadius: BorderRadius.circular(14).r,
      ),
      child: Row(
        children: [
          _stat(
            context.tr(AppStrings.successfulInvites),
            context.tr(
              AppStrings.peopleCount,
              args: ['${invitePoint.successfulInvites}'],
            ),
            loading: loading,
          ),
          divider(),
          _stat(
            context.tr(AppStrings.claimableRewards),
            _points(invitePoint.claimablePoint),
            loading: loading,
          ),
          divider(),
          _stat(
            context.tr(AppStrings.totalRewards),
            _points(invitePoint.totalClaimedPoint),
            loading: loading,
          ),
        ],
      ),
    );
  }

  /// [label] above [value]; only the value is a skeleton while [loading].
  Widget _stat(String label, String value, {required bool loading}) {
    return Expanded(
      child: Column(
        children: [
          AppText(
            label,
            fontSize: kFont12,
            color: AppColors.whiteColor,
            fontWeight: FontWeight.w500,
          ),
          AppSkeletonizer(
            enabled: loading,
            child: AppText(
              value,
              fontSize: kFont20,
              fontWeight: FontWeight.w600,
              color: AppColors.whiteColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _inviteCode(BuildContext context, InviteFriendsController controller) {
    final Color primary = context.color.primary;
    final String code = controller.inviteCode ?? '';

    return Container(
      padding: const EdgeInsets.all(14).r,
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(
            context.tr(AppStrings.myInviteCode),
            fontSize: kFont14,
            fontWeight: FontWeight.w500,
            color: AppColors.loginTextColor,
          ),
          10.heightSpace,
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(left: 12, right: 8).r,
                    decoration: BoxDecoration(
                      color: primary.wOpacity(0.06),
                      borderRadius: BorderRadius.circular(10).r,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppText(
                            code.isEmpty ? '-' : code,
                            fontSize: kFont16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.loginTextColor,
                            isOverflow: true,
                          ),
                        ),
                        if (code.isNotEmpty)
                          InkWellWrapper(
                            onTap: controller.onCopyCode,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ).r,
                              decoration: BoxDecoration(
                                border: Border.all(color: primary),
                                borderRadius: BorderRadius.circular(6).r,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Iconsax.copy_copy,
                                    size: 12.r,
                                    color: primary,
                                  ),
                                  3.widthSpace,
                                  AppText(
                                    context.tr(AppStrings.copy),
                                    fontSize: kFont11,
                                    fontWeight: FontWeight.w500,
                                    color: primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                10.widthSpace,
                AppButtonWidget(
                  text: context.tr(AppStrings.inviteNow),
                  isMinWidth: true,
                  textSize: kFont12,
                  buttonColor: AppColors.blackColor,
                  textColor: AppColors.whiteColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ).r,
                  onTap: code.isEmpty ? null : controller.onInvite,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const int _countFlex = 7;
  static const int _pointsFlex = 7;
  static const int _buttonFlex = 6;

  Widget _rewards(
    BuildContext context,
    InviteFriendsController controller,
    InvitePointModel invitePoint, {
    required bool loading,
  }) {
    final Color primary = context.color.primary;
    final EdgeInsets tableInset = const EdgeInsets.symmetric(horizontal: 12).r;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 4).r,
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(
            context.tr(AppStrings.claimRewardPoints),
            fontSize: kFont14,
            fontWeight: FontWeight.w500,
            color: AppColors.loginTextColor,
          ),
          12.heightSpace,
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: tableInset.copyWith(top: 11.r, bottom: 11.r),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(10).r,
                ),
                child: Row(
                  children: [
                    _headerCell(context.tr(AppStrings.inviteCount), _countFlex),
                    _headerCell(
                      context.tr(AppStrings.rewardPoints),
                      _pointsFlex,
                    ),
                    const Spacer(flex: _buttonFlex),
                  ],
                ),
              ),
              Positioned(
                right: 8.r,
                bottom: 5.r,
                child: Image.asset(
                  AppAssets.prize,
                  width: 90.r,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          14.heightSpace,

          // this round and its tiers: a skeleton while loading
          AppSkeletonizer(
            enabled: loading,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: tableInset.right),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppText(
                          context.tr(
                            AppStrings.roundRewards,
                            args: [_roundNumber(context, invitePoint.round)],
                          ),
                          fontSize: kFont14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.loginTextColor,
                        ),
                      ),
                      _smallButton(
                        text: context.tr(AppStrings.claimAll),
                        icon: Iconsax.gift,
                        onTap: invitePoint.canClaimAll
                            ? controller.onClaimAll
                            : null,
                      ),
                    ],
                  ),
                ),
                6.heightSpace,
                for (int i = 0; i < invitePoint.tiers.length; i++)
                  _tier(
                    context,
                    controller,
                    invitePoint.tiers[i],
                    inset: tableInset,
                    // no line under the last one
                    divider: i < invitePoint.tiers.length - 1,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String text, int flex) {
    return Expanded(
      flex: flex,
      child: AppText(
        text,
        fontSize: kFont13,
        fontWeight: FontWeight.w600,
        color: AppColors.whiteColor,
      ),
    );
  }

  Widget _tier(
    BuildContext context,
    InviteFriendsController controller,
    InvitePointTierModel tier, {
    required EdgeInsets inset,
    bool divider = true,
  }) {
    final double coinSize = 18.r;

    return Container(
      padding: inset.copyWith(top: 12.r, bottom: 12.r),
      decoration: divider
          ? const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.greyLight2Color),
              ),
            )
          : null,
      child: Row(
        children: [
          Expanded(
            flex: _countFlex,
            child: Row(
              children: [
                Icon(
                  Iconsax.user_add,
                  size: 16.r,
                  color: context.color.primary,
                ),
                6.widthSpace,
                AppText(
                  context.tr(
                    AppStrings.peopleCount,
                    args: ['${tier.position}'],
                  ),
                  fontSize: kFont14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.loginTextColor,
                ),
              ],
            ),
          ),
          Expanded(
            flex: _pointsFlex,
            child: Row(
              children: [
                Image.asset(
                  AppAssets.coins,
                  width: coinSize,
                  height: coinSize,
                  cacheWidth:
                      (coinSize * MediaQuery.devicePixelRatioOf(context))
                          .round(),
                ),
                6.widthSpace,
                AppText(
                  context.tr(
                    AppStrings.pointsAmount,
                    args: [_points(tier.pointAmount)],
                  ),
                  fontSize: kFont14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.loginTextColor,
                ),
              ],
            ),
          ),
          Expanded(
            flex: _buttonFlex,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: _tierButton(context, controller, tier),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tierButton(
    BuildContext context,
    InviteFriendsController controller,
    InvitePointTierModel tier,
  ) {
    if (tier.isAvailable) {
      return _smallButton(
        text: context.tr(AppStrings.claim),
        icon: Iconsax.gift,
        onTap: () => controller.onClaim(tier),
      );
    }

    return _smallButton(
      text: context.tr(
        tier.isLocked ? AppStrings.notUnlocked : AppStrings.claimed,
      ),
      icon: tier.isLocked ? Iconsax.lock : Iconsax.tick_circle,
      onTap: null,
    );
  }

  Widget _smallButton({
    required String text,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return AppButtonWidget(
      text: text,
      isMinWidth: true,
      radius: 6,
      textSize: kFont11,
      textColor: AppColors.whiteColor,
      icon: Icon(icon, size: 12.r, color: AppColors.whiteColor),
      iconSpace: 4,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6).r,
      onTap: onTap,
    );
  }

  /// "20,000", "0.1", "0".
  String _points(double value) => NumberFormat('#,##0.##').format(value);

  /// "一" for round 1 in Chinese (第一輪), digits otherwise.
  String _roundNumber(BuildContext context, int round) {
    const String numerals = '一二三四五六七八九十';

    return context.locale.languageCode == 'zh' && round >= 1 && round <= 10
        ? numerals[round - 1]
        : '$round';
  }

  /// White card with a hairline border and a soft shadow.
  BoxDecoration get _cardDecoration => BoxDecoration(
    color: AppColors.whiteColor,
    borderRadius: BorderRadius.circular(14).r,
    border: Border.all(color: AppColors.greyLight2Color),
    boxShadow: [
      BoxShadow(
        color: AppColors.blackColor.wOpacity(0.04),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );
}
