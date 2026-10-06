// Project imports:
import '../../imports.dart';

class AppBarWidget extends StatefulWidget implements PreferredSizeWidget {
  final bool? centerTitle;
  final Widget? title, leading;
  final List<Widget>? actions;
  final String? text;

  /// AppBar background
  final Color? backgroundColor;

  /// Optional widget below AppBar
  final Widget? bottomWidget;

  /// Title text config
  final double? textSize;
  final Color? textColor;

  /// Divider under AppBar
  final bool isDivider;
  final Color? dividerColor;

  /// Padding / leading control
  final bool paddingEnabled;

  /// Background behind transparent AppBar
  final Color? appBarBehindBackgroundColor;

  /// Gradient background (takes priority over backgroundColor)
  final Gradient? gradient;

  /// 🔥 Force status bar text/icon brightness (Android + iOS)
  /// If null → auto-detect
  final Brightness? statusBarIconBrightness;

  /// Disable toolbar height, only show safe area top
  final bool disableToolbarHeight;

  AppBarWidget({
    super.key,
    this.centerTitle = true,
    this.title,
    this.leading,
    this.actions,
    this.text,
    this.backgroundColor,
    this.bottomWidget,
    this.textSize,
    this.textColor,
    this.isDivider = true,
    this.dividerColor,
    this.paddingEnabled = true,
    this.appBarBehindBackgroundColor,
    this.statusBarIconBrightness,
    this.gradient,
    this.disableToolbarHeight = false,
  }) : preferredSize = Size.fromHeight(
         disableToolbarHeight
             ? 0
             : kToolbarHeight +
                   (bottomWidget != null ? 48.0 : 0.0) +
                   (isDivider ? 0.5 : 0),
       );

  @override
  final Size preferredSize;

  @override
  State<AppBarWidget> createState() => _AppBarWidgetState();
}

class _AppBarWidgetState extends State<AppBarWidget> {
  @override
  Widget build(BuildContext context) {
    return _buildAppBar(context);
  }

  Widget _buildAppBar(BuildContext context) {
    final bool isDarkTheme = context.color.brightness == Brightness.dark;

    /// 🔥 PRIORITY LOGIC
    /// 1. Use provided brightness
    /// 2. Else auto-detect from theme
    final Brightness resolvedBrightness =
        widget.statusBarIconBrightness ??
        (isDarkTheme ? Brightness.light : Brightness.dark);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            // Background color / gradient
            Positioned.fill(
              child: Container(
                decoration: widget.gradient != null
                    ? BoxDecoration(gradient: widget.gradient)
                    : BoxDecoration(
                        color: widget.backgroundColor ?? context.color.surface,
                      ),
              ),
            ),

            // Only show safe area top when toolbar is disabled
            if (widget.disableToolbarHeight)
              AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: resolvedBrightness,
                  statusBarBrightness: resolvedBrightness == Brightness.dark
                      ? Brightness.light
                      : Brightness.dark,
                ),
                child: const SizedBox(),
              )
            else
              AppBar(
                automaticallyImplyLeading: widget.paddingEnabled,
                centerTitle: widget.centerTitle,
                titleSpacing: widget.paddingEnabled ? null : 0,
                leadingWidth: widget.leading != null ? kToolbarHeight : 0,
                backgroundColor: widget.gradient != null
                    ? Colors.transparent
                    : (widget.backgroundColor ?? Colors.transparent),
                elevation: 0,
                shadowColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,

                /// ✅ ANDROID + IOS CORRECT HANDLING
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,

                  // Android icons
                  statusBarIconBrightness: resolvedBrightness,

                  // iOS text (OPPOSITE)
                  statusBarBrightness: resolvedBrightness == Brightness.dark
                      ? Brightness.light
                      : Brightness.dark,
                ),

                title: widget.text != null
                    ? AppText(
                        widget.text!,
                        color: widget.textColor ?? context.color.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: widget.textSize ?? kFont14,
                      )
                    : widget.title,

                leading: widget.leading ?? const SizedBox.shrink(),
                actions: widget.actions,

                iconTheme: IconThemeData(color: context.color.onSurface),
                actionsIconTheme: IconThemeData(color: context.color.onSurface),
              ),
          ],
        ),

        // Bottom widget
        if (widget.bottomWidget != null)
          Container(
            width: double.infinity,
            color: widget.backgroundColor ?? AppColors.whiteColor,
            child: widget.bottomWidget!,
          ),

        // Divider
        if (widget.isDivider)
          Container(
            height: 0.5,
            color: widget.dividerColor ?? AppColors.greyColor.wOpacity(0.3),
          ),
      ],
    );
  }
}
