// Project imports:
import '../../imports.dart';

class AppScaffold extends StatefulWidget {
  final List<Widget>? headerSlivers;
  final List<Widget>? headerWidgets;
  final Widget child;
  final Widget? bottomSheet;
  final Color? statusBarColor;
  final bool scrollEnabled;
  final Color? backgroundColor;
  final String? backgroundAsset;
  final bool nestedScrollViewEnabled;
  final SystemUiOverlayStyle? forceOverlayStyle;

  /// Optional external scroll controller
  final ScrollController? scrollController;

  /// Scroll listener support
  final void Function(double offset, bool isBeyondThreshold)? onScroll;

  /// Scroll threshold for `isBeyondThreshold`
  final double scrollThreshold;

  /// Optional content to show when beyond threshold
  final Widget? beyondContent;

  /// Control where beyondContent appears (default: topCenter)
  final Alignment beyondAlignment;

  final bool? resizeToAvoidBottomInset;
  final Widget? endDrawer;
  final void Function(bool)? onEndDrawerChanged;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const AppScaffold({
    super.key,
    required this.child,
    this.bottomSheet,
    this.headerSlivers,
    this.headerWidgets,
    this.statusBarColor,
    this.scrollEnabled = true,
    this.backgroundColor,
    this.backgroundAsset,
    this.nestedScrollViewEnabled = true,
    this.forceOverlayStyle,
    this.scrollController,
    this.onScroll,
    this.scrollThreshold = 100,
    this.beyondContent,
    this.beyondAlignment = Alignment.topCenter,
    this.resizeToAvoidBottomInset,
    this.endDrawer,
    this.onEndDrawerChanged,
    this.scaffoldKey,
  });

  /// Non-sliver layout (basic page)
  factory AppScaffold.basic({
    Key? key,
    required Widget child,
    List<Widget>? headerWidgets,
    Widget? bottomSheet,
    Color? statusBarColor,
    Color? backgroundColor,
    String? backgroundAsset,
    SystemUiOverlayStyle? forceOverlayStyle = SystemUiOverlayStyle.dark,
    bool? resizeToAvoidBottomInset,
    Widget? endDrawer,
    void Function(bool)? onEndDrawerChanged,
    GlobalKey<ScaffoldState>? scaffoldKey,
  }) {
    return AppScaffold(
      key: key,
      bottomSheet: bottomSheet,
      headerWidgets: headerWidgets,
      statusBarColor: statusBarColor,
      backgroundColor: backgroundColor,
      backgroundAsset: backgroundAsset,
      nestedScrollViewEnabled: false,
      forceOverlayStyle: forceOverlayStyle,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      endDrawer: endDrawer,
      scaffoldKey: scaffoldKey,
      onEndDrawerChanged: onEndDrawerChanged,
      child: child,
    );
  }

  /// Sliver layout (NestedScrollView)
  factory AppScaffold.sliver({
    Key? key,
    required Widget child,
    required List<Widget> headerSlivers,
    Widget? bottomSheet,
    Color? statusBarColor,
    bool scrollEnabled = true,
    Color? backgroundColor,
    String? backgroundAsset,
    SystemUiOverlayStyle? forceOverlayStyle,
    ScrollController? scrollController,
  }) {
    return AppScaffold(
      key: key,
      bottomSheet: bottomSheet,
      headerSlivers: headerSlivers,
      statusBarColor: statusBarColor,
      scrollEnabled: scrollEnabled,
      backgroundColor: backgroundColor,
      backgroundAsset: backgroundAsset,
      nestedScrollViewEnabled: true,
      forceOverlayStyle: forceOverlayStyle,
      scrollController: scrollController,
      child: child,
    );
  }

  /// Sliver layout with scroll listener & beyondContent support
  factory AppScaffold.sliverScrollListener({
    Key? key,
    required Widget child,
    required List<Widget> headerSlivers,
    Widget? bottomSheet,
    Color? statusBarColor,
    bool scrollEnabled = true,
    Color? backgroundColor,
    String? backgroundAsset,
    SystemUiOverlayStyle? forceOverlayStyle,
    void Function(double offset, bool isBeyondThreshold)? onScroll,
    double scrollThreshold = 100,
    ScrollController? scrollController,
    Widget? beyondContent,
    Alignment beyondAlignment = Alignment.topCenter,
  }) {
    return AppScaffold(
      key: key,
      bottomSheet: bottomSheet,
      headerSlivers: headerSlivers,
      statusBarColor: statusBarColor,
      scrollEnabled: scrollEnabled,
      backgroundColor: backgroundColor,
      backgroundAsset: backgroundAsset,
      nestedScrollViewEnabled: true,
      forceOverlayStyle: forceOverlayStyle,
      onScroll: onScroll,
      scrollThreshold: scrollThreshold,
      scrollController: scrollController,
      beyondContent: beyondContent,
      beyondAlignment: beyondAlignment,
      child: child,
    );
  }

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  late final ScrollController _internalScrollController;
  late final ValueNotifier<double> _statusBarOpacity;
  bool _isBeyondThreshold = false;

  ScrollController get _controller =>
      widget.scrollController ?? _internalScrollController;

  @override
  void initState() {
    super.initState();
    _internalScrollController = ScrollController();
    _statusBarOpacity = ValueNotifier(widget.scrollEnabled ? 0.0 : 1.0);

    if (widget.scrollEnabled) {
      _controller.addListener(_handleScroll);
    }
  }

  void _handleScroll() {
    final double offset = _controller.offset;
    final double threshold = widget.scrollThreshold;

    if (offset <= 0) {
      _statusBarOpacity.value = 0.0;
    } else if (offset >= 100) {
      _statusBarOpacity.value = 1.0;
    } else {
      _statusBarOpacity.value = (offset / 100).clamp(0.0, 1.0);
    }

    final bool newBeyond = offset >= threshold;
    if (newBeyond != _isBeyondThreshold) {
      setState(() {
        _isBeyondThreshold = newBeyond;
      });
    }

    widget.onScroll?.call(offset, _isBeyondThreshold);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleScroll);
    if (widget.scrollController == null) {
      _internalScrollController.dispose();
    }
    _statusBarOpacity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget content = widget.nestedScrollViewEnabled
        ? NestedScrollView(
            controller: _controller,
            physics: widget.scrollEnabled
                ? const AlwaysScrollableScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            headerSliverBuilder: (_, _) => widget.headerSlivers ?? [],
            body: widget.child,
          )
        : Scaffold(
            key: widget.scaffoldKey,
            resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
            backgroundColor: widget.backgroundColor ?? context.color.surface,
            endDrawer: widget.endDrawer,
            onEndDrawerChanged: widget.onEndDrawerChanged,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.headerWidgets != null) ...widget.headerWidgets!,
                Expanded(child: widget.child),
              ],
            ),
          );

    return UnfocusWrapper(
      child: Container(
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? context.color.surface,
        ),
        child: Stack(
          children: [
            if (widget.backgroundAsset != null)
              Positioned.fill(child: AppImage(name: widget.backgroundAsset)),

            // Main content
            content,

            // Beyond threshold content (shows dynamically)
            if (widget.beyondContent != null)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _isBeyondThreshold
                    ? Align(
                        alignment: widget.beyondAlignment,
                        child: widget.beyondContent,
                      )
                    : const SizedBox.shrink(),
              ),

            // Bottom sheet
            if (widget.bottomSheet != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: widget.bottomSheet!,
              ),

            // Status bar overlay style
            buildStatusBarOverlay(),
          ],
        ),
      ),
    );
  }

  // STATUS BAR OVERLAY (PRIORITY-BASED)
  Widget buildStatusBarOverlay() {
    final double statusBarHeight = ScreenUtil().statusBarHeight;

    // 1️⃣ Highest priority: fixed statusBarColor (no scroll logic)
    if (widget.statusBarColor != null) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value:
            widget.forceOverlayStyle ??
            (ThemeData.estimateBrightnessForColor(widget.statusBarColor!) ==
                    Brightness.dark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark),
        child: Container(height: statusBarHeight, color: widget.statusBarColor),
      );
    }

    // 2️⃣ Scroll-based logic (forceOverlayStyle participates)
    if (widget.scrollEnabled) {
      return ValueListenableBuilder<double>(
        valueListenable: _statusBarOpacity,
        builder: (_, opacity, _) {
          final bool isScrolled = opacity > 0.5;

          final SystemUiOverlayStyle overlayStyle = isScrolled
              ? SystemUiOverlayStyle.dark
              : (widget.forceOverlayStyle ?? SystemUiOverlayStyle.light);

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: overlayStyle,
            child: Container(
              height: statusBarHeight,
              color: Colors.white.wOpacity(opacity),
            ),
          );
        },
      );
    }

    // 3️⃣ Default fallback
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: widget.forceOverlayStyle ?? SystemUiOverlayStyle.dark,
      child: Container(height: statusBarHeight, color: Colors.transparent),
    );
  }
}
