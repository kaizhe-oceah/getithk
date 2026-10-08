// Project imports:
import '../../imports.dart';

class SmartRefresherWrapper extends StatelessWidget {
  final Widget? child;
  final bool enablePullUp;
  final bool enableTwoLevel;
  final bool enablePullDown;
  final VoidCallback? onRefresh;
  final VoidCallback? onLoading;
  final RefreshController controller;
  final ScrollController? scrollController;
  final ScrollPhysics? physics;
  final bool reverse;
  final bool? isLoading;
  final bool scrollShadowEnabled;
  final bool enableStartShadow;
  final bool enableEndShadow;
  final double? footerHeight;
  final TextStyle? textStyle;
  final Color? iconColor;
  final Color? footerTextColor;
  final bool alwaysShowStartShadow;

  const SmartRefresherWrapper({
    super.key,
    required this.controller,
    this.child,
    this.enablePullDown = true,
    this.enablePullUp = false,
    this.enableTwoLevel = false,
    this.onRefresh,
    this.onLoading,
    this.physics,
    this.scrollController,
    this.reverse = false,
    this.isLoading,
    this.scrollShadowEnabled = false,
    this.enableStartShadow = true,
    this.enableEndShadow = false,
    this.textStyle,
    this.iconColor,
    this.footerHeight,
    this.footerTextColor,
    this.alwaysShowStartShadow = false,
  });

  /// How the list springs back after a pull: critically damped, so it
  /// settles without overshooting (the package's default spring is
  /// under-damped and bounced after every refresh).
  static final SpringDescription _spring = SpringDescription.withDampingRatio(
    mass: 2.2,
    stiffness: 150,
  );

  @override
  Widget build(BuildContext context) {
    final Widget refresher = RefreshConfiguration(
      springDescription: _spring,
      child: mainWidget(context),
    );

    return scrollShadowEnabled
        ? ScrollShadow(
            enableStartShadow: enableStartShadow,
            enableEndShadow: enableEndShadow,
            alwaysShowStartShadow: alwaysShowStartShadow,
            child: refresher,
          )
        : refresher;
  }

  Widget mainWidget(BuildContext context) {
    return Stack(
      children: [
        SmartRefresher(
          // no bounce at either end; pulling down to refresh still works
          // (the package allows that much overscroll at the top)
          physics: physics ?? const ClampingScrollPhysics(),
          enablePullDown: enablePullDown,
          enablePullUp: enablePullUp,
          reverse: reverse,
          header: _LogoRefreshHeader(
            textStyle: textStyle ?? context.text.bodyMedium!,
            iconColor: iconColor ?? context.color.onSurface,
          ),
          footer: CustomFooter(
            height: footerHeight ?? 60.0,
            builder: (BuildContext context, LoadStatus? mode) {
              Widget body;

              if (mode == LoadStatus.idle) {
                body = AppText(
                  context.tr(AppStrings.pullUpToLoad),
                  color: footerTextColor,
                );
              } else if (mode == LoadStatus.failed) {
                body = AppText(
                  context.tr(AppStrings.loadFailTryAgain),
                  color: footerTextColor,
                );
              } else if (mode == LoadStatus.canLoading) {
                body = AppText(
                  context.tr(AppStrings.releaseToLoad),
                  color: footerTextColor,
                );
              } else if (mode == LoadStatus.loading) {
                body = Padding(
                  padding: const EdgeInsets.only(top: 10).r,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 32.fh,
                        width: 32.fh,
                        // the "refreshing" text beside it says it already
                        child: CircularProgressIndicatorWidget(
                          image: AppAssets.appLogo,
                          showText: false,
                        ),
                      ),
                      const SizedBox(width: 10),
                      AppText(
                        context.tr(AppStrings.refreshRefreshing),
                        color: footerTextColor,
                      ),
                    ],
                  ),
                );
              } else {
                body = Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 25,
                      height: 1,
                      color: AppColors.greyColor.wOpacity(0.5),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5).r,
                      child: AppText(
                        context.tr(AppStrings.loadNoData),
                        color:
                            footerTextColor ??
                            AppColors.greyColor.wOpacity(0.5),
                      ),
                    ),
                    Container(
                      width: 25,
                      height: 1,
                      color:
                          footerTextColor ?? AppColors.greyColor.wOpacity(0.5),
                    ),
                  ],
                );
              }

              return SizedBox(
                height: 55.0,
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10).r,
                    child: body,
                  ),
                ),
              );
            },
          ),
          controller: controller,
          onRefresh: onRefresh,
          onLoading: onLoading,
          scrollController: scrollController,
          child: child,
        ),
        if (isLoading != null)
          if (isLoading!)
            Center(
              child: CircularProgressIndicatorWidget(image: AppAssets.appLogo),
            ),
      ],
    );
  }
}

class CustomBouncingScrollPhysics extends BouncingScrollPhysics {
  final double stiffness; // higher = less bounce
  const CustomBouncingScrollPhysics({this.stiffness = 4.5, super.parent});

  // Higher stiffness = less bounce
  // Lower stiffness = more bounce
  @override
  CustomBouncingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomBouncingScrollPhysics(
      stiffness: stiffness,
      parent: buildParent(ancestor),
    );
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // Modify overscroll resistance (reduce bounce)
    final overscroll = super.applyBoundaryConditions(position, value);
    return overscroll / stiffness; // 👈 scale how much bounce occurs
  }
}

/// Pull-to-refresh header. The app logo turns with the pull (one full turn
/// by the time a release would refresh) and keeps spinning from that angle
/// while refreshing; when it's done a tick (or, on failure, a warning) fades
/// in in its place. A status line sits beside it.
class _LogoRefreshHeader extends RefreshIndicator {
  final TextStyle textStyle;
  final Color iconColor;

  const _LogoRefreshHeader({required this.textStyle, required this.iconColor});

  @override
  State<StatefulWidget> createState() => _LogoRefreshHeaderState();
}

class _LogoRefreshHeaderState extends RefreshIndicatorState<_LogoRefreshHeader>
    with SingleTickerProviderStateMixin {
  static const Duration _turnDuration = Duration(milliseconds: 700);

  // value = turns (0..1): follows the pull, then repeats (linearly, so the
  // speed is even) while refreshing, starting from the pulled angle.
  late final AnimationController _turns = AnimationController(
    vsync: this,
    duration: _turnDuration,
  );

  @override
  void onOffsetChange(double offset) {
    // only while the user is pulling: not while refreshing (floating) or
    // while the header slides away after it's done
    if (!floating &&
        (mode == RefreshStatus.idle || mode == RefreshStatus.canRefresh)) {
      final double trigger = configuration?.headerTriggerDistance ?? 80;
      _turns.value = (offset / trigger) % 1.0;
    }
    super.onOffsetChange(offset);
  }

  @override
  void onModeChange(RefreshStatus? mode) {
    if (mode == RefreshStatus.refreshing) {
      _turns.repeat();
    } else if (_turns.isAnimating) {
      // done: ease into the end of the current turn rather than freezing
      // mid-spin, while the tick fades in
      _turns.animateTo(
        1.0,
        duration: _turnDuration * (1.0 - _turns.value),
        curve: Curves.easeOut,
      );
    }
    super.onModeChange(mode);
  }

  @override
  void resetValue() {
    _turns.value = 0;
    super.resetValue();
  }

  @override
  void dispose() {
    _turns.dispose();
    super.dispose();
  }

  @override
  Widget buildContent(BuildContext context, RefreshStatus? mode) {
    final double iconSize = 25.fw;
    final String text = context.tr(switch (mode) {
      RefreshStatus.canRefresh => AppStrings.refreshReleaseToRefresh,
      RefreshStatus.refreshing => AppStrings.refreshRefreshing,
      RefreshStatus.completed => AppStrings.refreshCompleted,
      RefreshStatus.failed => AppStrings.refreshFailed,
      _ => AppStrings.refreshPullDownRefresh,
    });

    final Widget icon = switch (mode) {
      RefreshStatus.completed => Icon(
        Iconsax.tick_circle_copy,
        key: const ValueKey(RefreshStatus.completed),
        size: iconSize,
        color: widget.iconColor,
      ),
      RefreshStatus.failed => Icon(
        Iconsax.danger_copy,
        key: const ValueKey(RefreshStatus.failed),
        size: iconSize,
        color: widget.iconColor,
      ),
      _ => RepaintBoundary(
        key: const ValueKey('logo'),
        child: RotationTransition(
          turns: _turns,
          // same provider as AppLogo, so it's usually decoded already and the
          // first pull doesn't hitch; medium filtering keeps the edges smooth
          // while it turns
          child: Image.asset(
            AppAssets.appLogo,
            width: iconSize,
            height: iconSize,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
          ),
        ),
      ),
    };

    return SizedBox(
      height: widget.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              ),
              child: icon,
            ),
          ),
          10.widthSpace,
          Text(text, style: widget.textStyle),
        ],
      ),
    );
  }
}
