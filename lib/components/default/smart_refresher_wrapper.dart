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

  @override
  Widget build(BuildContext context) {
    return scrollShadowEnabled
        ? ScrollShadow(
            enableStartShadow: enableStartShadow,
            enableEndShadow: enableEndShadow,
            alwaysShowStartShadow: alwaysShowStartShadow,
            child: mainWidget(context),
          )
        : mainWidget(context);
  }

  Widget mainWidget(BuildContext context) {
    return Stack(
      children: [
        SmartRefresher(
          physics: physics ?? const CustomBouncingScrollPhysics(),
          enablePullDown: enablePullDown,
          enablePullUp: enablePullUp,
          reverse: reverse,
          header: ClassicHeader(
            idleText: context.tr(AppStrings.refreshPullDownRefresh),
            refreshingText: context.tr(AppStrings.refreshRefreshing),
            releaseText: context.tr(AppStrings.refreshReleaseToRefresh),
            completeText: context.tr(AppStrings.refreshCompleted),
            failedText: context.tr(AppStrings.refreshFailed),
            refreshingIcon: SizedBox(
              height: 32.fh,
              width: 32.fh,
              child: const CircularProgressIndicatorWidget(),
            ),
            failedIcon: Icon(
              Iconsax.danger_copy,
              color: iconColor ?? context.color.onSurface,
              size: 25.fw,
            ),
            completeIcon: Icon(
              Iconsax.tick_circle_copy,
              color: iconColor ?? context.color.onSurface,
              size: 25.fw,
            ),
            idleIcon: Icon(
              Iconsax.arrow_down_copy,
              color: iconColor ?? context.color.onSurface,
              size: 25.fw,
            ),
            releaseIcon: Icon(
              Iconsax.refresh_copy,
              color: iconColor ?? context.color.onSurface,
              size: 25.fw,
            ),
            textStyle: textStyle ?? context.text.bodyMedium!,
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
                        child: const CircularProgressIndicatorWidget(),
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
            const Center(child: CircularProgressIndicatorWidget()),
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
