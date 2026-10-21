// Project imports:
import '../../imports.dart';

class AppDropdown<T> extends StatefulWidget {
  const AppDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    required this.itemBuilder,
    this.buttonItemBuilder,
    this.hint,
    this.hintColor,
    this.width,
    this.height,
    this.itemHeight,
    this.padding,
    this.radius = 8,
    this.iconSize,
    this.backgroundColor = AppColors.whiteColor,
    this.borderColor,
    this.foregroundColor,
    this.boxShadow,
    this.tintSelected = true,
  });

  final List<T> items;
  final T? value;
  final ValueChanged<T> onChanged;

  /// An option's content in [color]: the foreground on the button, primary
  /// for the picked option in the menu, the text colour for the rest.
  final Widget Function(BuildContext context, T item, Color color) itemBuilder;

  /// Overrides how the picked item appears on the closed button.
  final Widget Function(BuildContext context, T item, Color color)?
  buttonItemBuilder;

  /// Shown on the button while nothing is picked.
  final String? hint;
  final Color? hintColor;

  /// The button's width, which the menu matches; null fills what it's given.
  final double? width;

  /// The button's height; null fits its content and [padding].
  final double? height;

  /// Each option's height in the menu; [height] by default, else 48.
  final double? itemHeight;

  final EdgeInsets? padding;
  final double radius;
  final double? iconSize;
  final Color backgroundColor;
  final Color? borderColor;
  final Color? foregroundColor;
  final List<BoxShadow>? boxShadow;

  /// Whether the picked option's row in the menu gets a primary tint behind it.
  final bool tintSelected;

  /// The gap before the ▾ and its default size, for sizing a button to fit
  /// its longest label.
  static double get iconGap => 4.r;
  static double get defaultIconSize => 12.r;

  static EdgeInsets get defaultPadding =>
      const EdgeInsets.symmetric(horizontal: 12, vertical: 6).r;

  @override
  State<AppDropdown<T>> createState() => _AppDropdownState<T>();
}

class _AppDropdownState<T> extends State<AppDropdown<T>> {
  // the button and the menu's options both read the pick from here
  late final ValueNotifier<T?> _selected = ValueNotifier(widget.value);

  @override
  void didUpdateWidget(covariant AppDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _selected.value = widget.value;
  }

  @override
  void dispose() {
    _selected.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = context.color.primary;
    final Color foreground = widget.foregroundColor ?? primary;
    final BorderRadius radius = BorderRadius.circular(widget.radius).r;
    final EdgeInsets padding = widget.padding ?? AppDropdown.defaultPadding;

    return DropdownButtonHideUnderline(
      child: DropdownButton2<T>(
        valueListenable: _selected,
        onChanged: (value) {
          if (value == null) return;
          _selected.value = value;
          widget.onChanged(value);
        },
        items: [
          for (final T item in widget.items)
            DropdownItem(
              value: item,
              height: widget.itemHeight ?? widget.height ?? 48.r,
              child: ValueListenableBuilder<T?>(
                valueListenable: _selected,
                builder: (context, selected, _) => widget.itemBuilder(
                  context,
                  item,
                  selected == item ? primary : AppColors.loginTextColor,
                ),
              ),
            ),
        ],
        customButton: ValueListenableBuilder<T?>(
          valueListenable: _selected,
          builder: (context, selected, _) => Container(
            width: widget.width,
            height: widget.height,
            padding: padding,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              border: Border.all(color: widget.borderColor ?? foreground),
              borderRadius: radius,
              boxShadow: widget.boxShadow,
            ),
            // the label where the menu's options start, the ▾ at the end
            child: Row(
              children: [
                Expanded(
                  child: selected == null
                      ? AppText(
                          widget.hint ??
                              context.tr(AppStrings.pleaseSelectAnItem),
                          color:
                              widget.hintColor ??
                              AppColors.hintColor.wOpacity(0.75),
                          isOverflow: true,
                        )
                      : (widget.buttonItemBuilder ?? widget.itemBuilder)(
                          context,
                          selected,
                          foreground,
                        ),
                ),
                SizedBox(width: AppDropdown.iconGap),
                Icon(
                  Iconsax.arrow_down,
                  size: widget.iconSize ?? AppDropdown.defaultIconSize,
                  color: foreground,
                ),
              ],
            ),
          ),
        ),
        buttonStyleData: const ButtonStyleData(
          overlayColor: WidgetStateColor.transparent,
        ),
        dropdownStyleData: DropdownStyleData(
          // a long list scrolls below the button instead of covering it
          maxHeight: 0.4.sh,
          offset: Offset(0, -4.r),
          elevation: 0,
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: radius,
            border: Border.all(color: AppColors.greyLight2Color),
            boxShadow: [
              BoxShadow(
                color: AppColors.blackColor.wOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        menuItemStyleData: MenuItemStyleData(
          // inset like the button's label, so the text lines up
          padding: EdgeInsets.symmetric(horizontal: padding.left),
          selectedMenuItemBuilder: (context, child) => widget.tintSelected
              ? ColoredBox(color: primary.wOpacity(0.06), child: child)
              : child,
        ),
      ),
    );
  }
}
