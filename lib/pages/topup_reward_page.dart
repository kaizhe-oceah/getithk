// Flutter imports:
import 'package:flutter/rendering.dart' show RenderAbstractViewport;

// Project imports:
import '../components/sub_product/sub_product_parts.dart';
import '../controllers/topup_reward_controller.dart';
import '../imports.dart';
import '../models/accumulate_box_model.dart';
import '../models/sub_product_model.dart';

class TopupRewardPage extends StatelessWidget {
  const TopupRewardPage({super.key});

  static const Duration _switchDuration = Duration(milliseconds: 250);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TopupRewardController(),
      child: AppScaffold.basic(
        backgroundColor: AppColors.greyBackgroundColor,
        forceOverlayStyle: SystemUiOverlayStyle.dark,
        headerWidgets: [
          AppBarWidget(
            text: context.tr(AppStrings.topupReward),
            backgroundColor: AppColors.whiteColor,
            leading: const AppBarBackButton(),
          ),
        ],
        child: Consumer<TopupRewardController>(
          builder: (context, controller, _) => _content(context, controller),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, TopupRewardController controller) {
    final bool skeleton = controller.isLoading && controller.levels.isEmpty;
    final List<AccumulateBoxModel> levels = skeleton
        ? List.generate(3, (_) => AccumulateBoxModel.placeholder())
        : controller.levels;
    final AccumulateBoxModel? level = skeleton
        ? levels.first
        : controller.selected;
    final String currency =
        context.read<AppController>().user?.currencyCode ?? 'HKD';

    return SmartRefresherWrapper(
      controller: controller.refreshController,
      onRefresh: controller.onRefresh,
      child: level == null
          ? const CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: NoDataWidget()),
                ),
              ],
            )
          : ListView(
              padding: EdgeInsets.fromLTRB(
                kHorizontalPadding.r,
                12.r,
                kHorizontalPadding.r,
                20.r + MediaQuery.paddingOf(context).bottom,
              ),
              children: [
                AppSkeletonizer(
                  enabled: skeleton,
                  child: _levels(
                    context,
                    controller,
                    levels,
                    currency,
                    skeleton: skeleton,
                  ),
                ),
                12.heightSpace,
                _reward(context, level, currency, skeleton: skeleton),
                16.heightSpace,
                _claimButton(context, controller, level, skeleton: skeleton),
                16.heightSpace,
                AppSkeletonizer(
                  enabled: skeleton,
                  child: _prizes(context, level),
                ),
              ],
            ),
    );
  }

  Widget _levels(
    BuildContext context,
    TopupRewardController controller,
    List<AccumulateBoxModel> levels,
    String currency, {
    required bool skeleton,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12).r,
      decoration: _cardDecoration,
      child: _LevelsRow(
        key: ValueKey(skeleton),
        selectedIndex: controller.selectedIndex,
        separator: _dashes(),
        levels: [
          for (int i = 0; i < levels.length; i++)
            _level(
              context,
              levels[i],
              currency,
              selected: i == controller.selectedIndex,
              onTap: () => controller.onSelect(i),
            ),
        ],
      ),
    );
  }

  /// HKD 100 over 已通過 (a star) or 還未解鎖 (a lock): filled in primary
  /// when picked, tinted when reached, grey when not.
  Widget _level(
    BuildContext context,
    AccumulateBoxModel level,
    String currency, {
    required bool selected,
    required VoidCallback onTap,
  }) {
    final Color primary = context.color.primary;
    final Color accent = level.isLocked && !selected
        ? AppColors.textLightColor
        : primary;
    final Color foreground = selected ? AppColors.whiteColor : accent;
    final double badgeSize = 22.r;

    return InkWellWrapper(
      onTap: onTap,
      child: AnimatedContainer(
        duration: _switchDuration,
        padding: const EdgeInsets.fromLTRB(8, 7, 12, 7).r,
        decoration: BoxDecoration(
          color: selected
              ? primary
              : level.isLocked
              ? AppColors.greyBackgroundColor
              : primary.wOpacity(0.08),
          borderRadius: BorderRadius.circular(8).r,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                color: selected ? AppColors.whiteColor : accent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                level.isLocked ? Icons.lock_rounded : Icons.star_rounded,
                size: 14.r,
                color: selected ? primary : AppColors.whiteColor,
              ),
            ),
            8.widthSpace,
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  '$currency ${_amount(level.requiredTopupAmount)}',
                  fontSize: kFont13,
                  fontWeight: FontWeight.w700,
                  color: foreground,
                ),
                AppText(
                  context.tr(
                    level.isLocked
                        ? AppStrings.notUnlocked
                        : AppStrings.levelPassed,
                  ),
                  fontSize: kFont11,
                  color: foreground,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashes() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6).r,
      child: Row(
        children: [
          for (int i = 0; i < 4; i++) ...[
            if (i > 0) SizedBox(width: 3.r),
            Container(
              width: 4.r,
              height: 1.5.r,
              color: AppColors.greyLightColor,
            ),
          ],
        ],
      ),
    );
  }

  Widget _reward(
    BuildContext context,
    AccumulateBoxModel level,
    String currency, {
    required bool skeleton,
  }) {
    final Color primary = context.color.primary;
    final double imageSize = 108.r;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 0, 16).r,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color.alphaBlend(primary.wOpacity(0.07), AppColors.whiteColor),
            Color.alphaBlend(primary.wOpacity(0.36), AppColors.whiteColor),
          ],
        ),
        borderRadius: BorderRadius.circular(14).r,
      ),
      child: Row(
        children: [
          Expanded(
            child: AppSkeletonizer(
              enabled: skeleton,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    context.tr(AppStrings.accumulatedTopupReward),
                    fontSize: kFont17,
                    fontWeight: FontWeight.w600,
                  ),
                  6.heightSpace,
                  _highlighted(
                    context,
                    AppStrings.topupToUnlockReward,
                    highlight:
                        '$currency ${_amount(level.requiredTopupAmount)}',
                  ),
                  12.heightSpace,
                  _progressBar(context, level.progress),
                  10.heightSpace,
                  _highlighted(
                    context,
                    AppStrings.accumulatedTopup,
                    highlight: '$currency ${_amount(level.currentTopupAmount)}',
                    rest: '$currency ${_amount(level.requiredTopupAmount)}',
                  ),
                ],
              ),
            ),
          ),
          20.widthSpace,
          if (skeleton)
            _ImagePlaceholder(size: imageSize)
          else
            AppImage(
              key: ValueKey(level.image),
              name: level.image,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.contain,
              placeholder: _ImagePlaceholder(size: imageSize),
            ),
        ],
      ),
    );
  }

  Widget _highlighted(
    BuildContext context,
    String key, {
    required String highlight,
    String? rest,
  }) {
    const TextStyle style = TextStyle(
      fontSize: kFont15,
      color: AppColors.loginTextColor,
    );
    final List<String> parts = context.tr(key).split('{}');

    return Text.rich(
      TextSpan(
        style: style,
        children: [
          for (int i = 0; i < parts.length; i++) ...[
            TextSpan(text: parts[i]),
            if (i == 0 && parts.length > 1)
              TextSpan(
                text: highlight,
                style: style.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.color.primary,
                ),
              ),
            if (i == 1 && parts.length > 2) TextSpan(text: rest ?? ''),
          ],
        ],
      ),
    );
  }

  /// Fills to [value] (0 to 1), easing to a new one.
  Widget _progressBar(BuildContext context, double value) {
    final Color primary = context.color.primary;
    final BorderRadius radius = BorderRadius.circular(100);

    return Container(
      height: 8.r,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: primary.wOpacity(0.15),
        borderRadius: radius,
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: value),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        builder: (context, value, _) => FractionallySizedBox(
          widthFactor: value,
          child: Container(
            decoration: BoxDecoration(color: primary, borderRadius: radius),
          ),
        ),
      ),
    );
  }

  Widget _claimButton(
    BuildContext context,
    TopupRewardController controller,
    AccumulateBoxModel level, {
    required bool skeleton,
  }) {
    return Center(
      child: SizedBox(
        width: 200.r,
        child: AppButtonWidget(
          text: context.tr(AppStrings.claimReward),
          radius: 10,
          fontWeight: FontWeight.w600,
          textColor: AppColors.whiteColor,
          gradient: AppColors.brandGradientColor,
          padding: const EdgeInsets.symmetric(vertical: 8).r,
          onTap: !skeleton && level.canClaim ? controller.onClaim : null,
        ),
      ),
    );
  }

  /// 本階段可抽獎品: the level's prizes, two to a row, fading over to
  /// another level's.
  Widget _prizes(BuildContext context, AccumulateBoxModel level) {
    return Container(
      padding: const EdgeInsets.all(14).r,
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AppText(
                context.tr(AppStrings.prizesThisLevel),
                fontSize: kFont15,
                fontWeight: FontWeight.w700,
              ),
              8.widthSpace,
              Expanded(
                child: AppText(
                  context.tr(AppStrings.prizePoolByLevel),
                  fontSize: kFont11,
                  color: AppColors.textLightColor,
                  textAlign: TextAlign.end,
                  isOverflow: true,
                ),
              ),
            ],
          ),
          12.heightSpace,
          AnimatedSwitcher(
            duration: _switchDuration,
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.topCenter,
              children: [...previous, ?current],
            ),
            child: KeyedSubtree(
              key: ObjectKey(level),
              child: level.subProducts.isEmpty
                  ? const NoDataWidget()
                  : _prizeGrid(level.subProducts),
            ),
          ),
        ],
      ),
    );
  }

  Widget _prizeGrid(List<SubProductModel> prizes) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double spacing = 10.r;
        final double tileWidth = (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: 14.r,
          children: [
            for (final SubProductModel prize in prizes)
              SubProductTile(
                product: prize,
                width: tileWidth,
                // a blind box's prizes: their chance, not their grade
                showGradeInDialog: false,
                showChanceInDialog: true,
              ),
          ],
        );
      },
    );
  }

  /// "200,600", "1,000", "0.5".
  String _amount(double value) => NumberFormat('#,##0.##').format(value);

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

/// [levels] in a sideways scroll, [separator] between them, the one at
/// [selectedIndex] in its middle (or as near as the ends allow): eased there
/// when it changes, straight there when the row first shows. Only the row
/// scrolls, never the page.
class _LevelsRow extends StatefulWidget {
  final int selectedIndex;
  final Widget separator;
  final List<Widget> levels;

  const _LevelsRow({
    required this.selectedIndex,
    required this.separator,
    required this.levels,
    super.key,
  });

  @override
  State<_LevelsRow> createState() => _LevelsRowState();
}

class _LevelsRowState extends State<_LevelsRow> {
  final ScrollController _scroll = ScrollController();

  /// Each level's place in the row, to scroll to.
  final Map<int, BuildContext> _levelContexts = {};

  @override
  void initState() {
    super.initState();
    _centreSelected(animate: false);
  }

  @override
  void didUpdateWidget(_LevelsRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _centreSelected(animate: true);
    }
  }

  /// Once laid out, the picked level to the middle.
  void _centreSelected({required bool animate}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BuildContext? level = _levelContexts[widget.selectedIndex];
      if (!mounted || !_scroll.hasClients || level == null || !level.mounted) {
        return;
      }

      final RenderObject box = level.findRenderObject()!;
      final ScrollPosition position = _scroll.position;
      final double offset = RenderAbstractViewport.of(box)
          .getOffsetToReveal(box, 0.5)
          .offset
          .clamp(position.minScrollExtent, position.maxScrollExtent);

      if (animate) {
        _scroll.animateTo(
          offset,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      } else {
        _scroll.jumpTo(offset);
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scroll,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12).r,
      child: Row(
        children: [
          for (int i = 0; i < widget.levels.length; i++) ...[
            if (i > 0) widget.separator,
            Builder(
              builder: (levelContext) {
                _levelContexts[i] = levelContext;
                return widget.levels[i];
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// The box image's stand-in while it loads: a white circle gently pulsing
/// on the card's pink.
class _ImagePlaceholder extends StatefulWidget {
  final double size;

  const _ImagePlaceholder({required this.size});

  @override
  State<_ImagePlaceholder> createState() => _ImagePlaceholderState();
}

class _ImagePlaceholderState extends State<_ImagePlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final Animation<double> _opacity = Tween<double>(
    begin: 0.35,
    end: 0.75,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double circle = widget.size * 0.8;

    return SizedBox.square(
      dimension: widget.size,
      child: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: Container(
            width: circle,
            height: circle,
            decoration: const BoxDecoration(
              color: AppColors.whiteColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
