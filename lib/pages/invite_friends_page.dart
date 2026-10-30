// Flutter imports:
import 'package:flutter/rendering.dart' show RenderProxyBox;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../components/invite/invite_parts.dart';
import '../controllers/invite_friends_controller.dart';
import '../imports.dart';
import '../models/invite_point_model.dart';

class InviteFriendsPage extends StatelessWidget {
  const InviteFriendsPage({super.key});

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
          const InviteHeader(
            title: AppStrings.inviteTitle,
            chip: AppStrings.inviteFreePoints,
            description: AppStrings.inviteDescription,
            steps: [
              (Iconsax.link_21_copy, AppStrings.inviteStepShare),
              (Iconsax.user_add_copy, AppStrings.inviteStepRegister),
              (Iconsax.coin_copy, AppStrings.inviteStepTopUp),
              (Iconsax.gift_copy, AppStrings.inviteStepPoints),
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
                  args: ['${invitePoint.successfulInvites}'],
                ),
              ),
              (
                context.tr(AppStrings.claimableRewards),
                _points(invitePoint.claimablePoint),
              ),
              (
                context.tr(AppStrings.totalRewards),
                _points(invitePoint.totalClaimedPoint),
              ),
            ],
          ),
          12.heightSpace,
          const InviteCodeCard(),
          12.heightSpace,
          _rewards(context, controller),
        ],
      ),
    );
  }

  static const int _countFlex = 7;
  static const int _pointsFlex = 7;
  static const int _buttonFlex = 6;

  Widget _rewards(BuildContext context, InviteFriendsController controller) {
    final Color primary = context.color.primary;
    final EdgeInsets tableInset = const EdgeInsets.symmetric(horizontal: 12).r;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 4).r,
      decoration: inviteCardDecoration,
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
          if (controller.totalRounds > 1)
            _RoundPager(
              initialRound: controller.round,
              totalRounds: controller.totalRounds,
              onRoundChanged: controller.onSelectRound,
              hintBuilder: (pages) =>
                  _swipeHint(context, pages, controller.totalRounds),
              roundBuilder: (context, round) =>
                  _round(context, controller, round, inset: tableInset),
            )
          else
            _round(context, controller, controller.round, inset: tableInset),
        ],
      ),
    );
  }

  /// ◀ 左右滑動查看獎勵 ▶, then a dot per round, the one on show in primary
  /// and sliding along with the swipe.
  Widget _swipeHint(BuildContext context, PageController pages, int count) {
    final Color primary = context.color.primary;
    final double dotSize = 6.r;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 2).r,
          decoration: BoxDecoration(
            color: primary.wOpacity(0.1),
            borderRadius: BorderRadius.circular(4).r,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_left_rounded, size: 18.r, color: primary),
              AppText(
                context.tr(AppStrings.swipeToViewRewards),
                fontSize: kFont11,
                fontWeight: FontWeight.w500,
                color: primary,
              ),
              Icon(Icons.arrow_right_rounded, size: 18.r, color: primary),
            ],
          ),
        ),
        8.widthSpace,
        SmoothPageIndicator(
          controller: pages,
          count: count,
          effect: WormEffect(
            dotWidth: dotSize,
            dotHeight: dotSize,
            spacing: 4.r,
            activeDotColor: primary,
            dotColor: AppColors.greyLightColor,
          ),
        ),
      ],
    );
  }

  Widget _round(
    BuildContext context,
    InviteFriendsController controller,
    int round, {
    required EdgeInsets inset,
  }) {
    final bool loading = controller.isRoundLoading(round);
    final InvitePointModel roundPoint =
        controller.rounds[round] ??
        (loading
            ? InvitePointModel.placeholder()
            : InvitePointModel.fromJson({}));

    return AppSkeletonizer(
      enabled: loading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.only(right: inset.right),
            child: Row(
              children: [
                Expanded(
                  child: AppText(
                    context.tr(
                      AppStrings.roundRewards,
                      args: [_roundNumber(context, round)],
                    ),
                    fontSize: kFont14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.loginTextColor,
                  ),
                ),
                _smallButton(
                  text: context.tr(AppStrings.claimAll),
                  icon: Iconsax.gift,
                  onTap: roundPoint.hasAvailableTier
                      ? () => controller.onClaimRound(round)
                      : null,
                ),
              ],
            ),
          ),
          6.heightSpace,
          for (int i = 0; i < roundPoint.tiers.length; i++)
            _tier(
              context,
              controller,
              round,
              roundPoint.tiers[i],
              inset: inset,
              divider: i < roundPoint.tiers.length - 1,
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
    int round,
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
              child: _tierButton(context, controller, round, tier),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tierButton(
    BuildContext context,
    InviteFriendsController controller,
    int round,
    InvitePointTierModel tier,
  ) {
    if (tier.isAvailable) {
      return _smallButton(
        text: context.tr(AppStrings.claim),
        icon: Iconsax.gift,
        onTap: () => controller.onClaim(round, tier),
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

  String _points(double value) => NumberFormat('#,##0.##').format(value);
  String _roundNumber(BuildContext context, int round) {
    const String numerals = '一二三四五六七八九十';

    return context.locale.languageCode == 'zh' && round >= 1 && round <= 10
        ? numerals[round - 1]
        : '$round';
  }

}

class _RoundPager extends StatefulWidget {
  final int initialRound;
  final int totalRounds;
  final ValueChanged<int> onRoundChanged;
  final Widget Function(PageController pages) hintBuilder;
  final Widget Function(BuildContext context, int round) roundBuilder;

  const _RoundPager({
    required this.initialRound,
    required this.totalRounds,
    required this.onRoundChanged,
    required this.hintBuilder,
    required this.roundBuilder,
  });

  @override
  State<_RoundPager> createState() => _RoundPagerState();
}

class _RoundPagerState extends State<_RoundPager> {
  late final PageController _pages = PageController(
    initialPage: widget.initialRound - 1,
  );

  final Map<int, double> _heights = {};

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  double get _page =>
      _pages.hasClients && _pages.position.haveDimensions
      ? _pages.page ?? _pages.initialPage.toDouble()
      : _pages.initialPage.toDouble();

  double get _height {
    final double page = _page;
    final int from = page.floor();
    final int to = page.ceil();
    final double fromHeight = _heights[from] ?? _heights[to] ?? 0;
    final double toHeight = _heights[to] ?? fromHeight;

    return fromHeight + (toHeight - fromHeight) * (page - from);
  }

  void _onMeasured(int index, double height) {
    if (!mounted || _heights[index] == height) return;
    setState(() => _heights[index] = height);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        widget.hintBuilder(_pages),
        10.heightSpace,
        _pager(),
      ],
    );
  }

  Widget _pager() {
    return AnimatedBuilder(
      animation: _pages,
      builder: (context, child) => SizedBox(height: _height, child: child),
      child: PageView.builder(
        controller: _pages,
        itemCount: widget.totalRounds,
        onPageChanged: (index) => widget.onRoundChanged(index + 1),
        itemBuilder: (context, index) => OverflowBox(
          alignment: Alignment.topCenter,
          minHeight: 0,
          maxHeight: double.infinity,
          child: _MeasureHeight(
            onChange: (height) => _onMeasured(index, height),
            child: widget.roundBuilder(context, index + 1),
          ),
        ),
      ),
    );
  }
}

class _MeasureHeight extends SingleChildRenderObjectWidget {
  final ValueChanged<double> onChange;

  const _MeasureHeight({required this.onChange, required super.child});

  @override
  _RenderMeasureHeight createRenderObject(BuildContext context) =>
      _RenderMeasureHeight(onChange);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderMeasureHeight renderObject,
  ) => renderObject.onChange = onChange;
}

class _RenderMeasureHeight extends RenderProxyBox {
  ValueChanged<double> onChange;
  double? _last;

  _RenderMeasureHeight(this.onChange);

  @override
  void performLayout() {
    super.performLayout();
    final double height = size.height;
    if (height == _last) return;

    _last = height;
    WidgetsBinding.instance.addPostFrameCallback((_) => onChange(height));
  }
}
