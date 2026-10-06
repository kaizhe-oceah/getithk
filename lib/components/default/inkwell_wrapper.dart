// Project imports:
import '../../imports.dart';

class InkWellWrapper extends StatefulWidget {
  final Widget child;
  final Function()? onTap;
  final Function()? onDoubleTap;
  final Function()? onLongPress;
  final Function()? onLongPressUp;
  final Function(TapDownDetails)? onTapDown;
  final Function(TapUpDetails)? onTapUp;
  final Function()? onTapCancel;
  final Function()? onSecondaryTap;
  final Function(TapUpDetails)? onSecondaryTapUp;
  final Function(TapDownDetails)? onSecondaryTapDown;
  final Function()? onSecondaryTapCancel;
  final Function(bool)? onHighlightChanged;
  final Function(bool)? onHover;
  final MouseCursor? mouseCursor;
  final Color? focusColor;
  final Color? hoverColor;
  final Color? highlightColor;
  final WidgetStateProperty<Color?>? overlayColor;
  final Color? splashColor;
  final InteractiveInkFeatureFactory? splashFactory;
  final double? radius;
  final BorderRadius? borderRadius;
  final ShapeBorder? customBorder;
  final bool enableFeedback;
  final bool excludeFromSemantics;
  final FocusNode? focusNode;
  final bool canRequestFocus;
  final Function(bool)? onFocusChange;
  final bool autofocus;
  final WidgetStatesController? statesController;
  final Duration? hoverDuration;
  final bool checkLogin;
  final Duration cooldownDuration;
  final bool keyboardCheckingEnabled;

  const InkWellWrapper({
    super.key,
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onLongPressUp,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.onSecondaryTap,
    this.onSecondaryTapUp,
    this.onSecondaryTapDown,
    this.onSecondaryTapCancel,
    this.onHighlightChanged,
    this.onHover,
    this.mouseCursor,
    this.focusColor = Colors.transparent,
    this.hoverColor = Colors.transparent,
    this.highlightColor = Colors.transparent,
    this.overlayColor,
    this.splashColor = Colors.transparent,
    this.splashFactory,
    this.radius,
    this.borderRadius,
    this.customBorder,
    this.enableFeedback = true,
    this.excludeFromSemantics = false,
    this.focusNode,
    this.canRequestFocus = true,
    this.onFocusChange,
    this.autofocus = false,
    this.statesController,
    this.hoverDuration,
    this.checkLogin = false,
    this.keyboardCheckingEnabled = false,
    this.cooldownDuration = const Duration(milliseconds: 0),
  });

  @override
  State<InkWellWrapper> createState() => _InkWellWrapperState();
}

class _InkWellWrapperState extends State<InkWellWrapper> {
  bool _isTapped = false;

  void _handleTap() async {
    if (_isTapped) return;

    // Check if keyboard is open, then unfocus
    if (widget.keyboardCheckingEnabled) {
      final bool isKeyboardVisible =
          KeyboardVisibilityProvider.isKeyboardVisible(context);
      if (isKeyboardVisible) {
        unfocusKeyboard();
        return;
      }
    }

    setState(() => _isTapped = true);

    if (widget.checkLogin) {
      final user = context.read<AppController>().user;
      if (user == null) {
        AppNavigator.pushNamed(context, RouteName.loginPage);
        if (mounted) setState(() => _isTapped = false);
        return;
      }
    }

    if (widget.onTap != null) {
      unfocusKeyboard();
      widget.onTap!();
    }

    // Prevent tapping again
    await Future.delayed(widget.cooldownDuration);
    if (mounted) setState(() => _isTapped = false);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _handleTap,
      onDoubleTap: widget.onDoubleTap,
      onLongPress: widget.onLongPress,
      onLongPressUp: widget.onLongPressUp,
      onTapDown: widget.onTapDown,
      onTapUp: widget.onTapUp,
      onTapCancel: widget.onTapCancel,
      onSecondaryTap: widget.onSecondaryTap,
      onSecondaryTapUp: widget.onSecondaryTapUp,
      onSecondaryTapDown: widget.onSecondaryTapDown,
      onSecondaryTapCancel: widget.onSecondaryTapCancel,
      onHighlightChanged: widget.onHighlightChanged,
      onHover: widget.onHover,
      mouseCursor: widget.mouseCursor,
      focusColor: widget.focusColor,
      hoverColor: widget.hoverColor,
      highlightColor: widget.highlightColor,
      overlayColor: widget.overlayColor,
      splashColor: widget.splashColor,
      splashFactory: widget.splashFactory,
      radius: widget.radius,
      borderRadius: widget.borderRadius,
      customBorder: widget.customBorder,
      enableFeedback: widget.enableFeedback,
      excludeFromSemantics: widget.excludeFromSemantics,
      focusNode: widget.focusNode,
      canRequestFocus: widget.canRequestFocus,
      onFocusChange: widget.onFocusChange,
      autofocus: widget.autofocus,
      statesController: widget.statesController,
      hoverDuration: widget.hoverDuration,
      child: widget.child,
    );
  }
}
