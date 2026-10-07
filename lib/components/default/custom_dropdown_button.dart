// Project imports:
import '../../imports.dart';

typedef NullableDropdownItemBuilder<T> =
    DropdownItem<T>? Function(BuildContext context, int index);
typedef NullableSelectedItemBuilder<T> =
    DropdownMenuItem<T>? Function(BuildContext context, int index);
typedef OnChanged<T> = void Function(T item);

class CustomDropdownButton<T> extends StatefulWidget {
  final List<T> dataList;
  final NullableDropdownItemBuilder<T> dropdownItemBuilder;
  final NullableSelectedItemBuilder<T> selectedItemBuilder;
  final OnChanged<T?> onChanged;
  final double? height;
  final double? width;
  final String? hint;
  final double? hintFontSize;
  final Color? hintColor;
  final Color? backgroundColor;
  final Color? dropDownBackgroundColor;
  final double? radius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final EdgeInsetsGeometry? padding;
  final Widget? customButton;
  final bool enabledBoxDecoration;
  final DropdownStyleData? dropdownStyleData;
  final T? initItem;
  final bool Function(DropdownItem<T>, String)? searchMatchFn;
  final String? searchHintText;
  final String? errorText;
  final FormFieldValidator<T>? validator;
  final IconStyleData? iconStyleData;

  // chip mode
  final bool chipMode;
  final List<T> chipItems;
  final Widget Function(BuildContext context, T item)? chipBuilder;
  final void Function(T item)? onChipRemoved;

  //label
  final String? labelText;
  final double? labelTextSize;
  final double labelPaddingBottom;
  final FontWeight? labelFontWeight;
  final bool labelIsRequired;
  final Widget? labelSuffixChild;
  final Color? labelColor;
  final Widget? labelImage; // label for image

  const CustomDropdownButton({
    super.key,
    required this.dataList,
    required this.onChanged,
    required this.dropdownItemBuilder,
    required this.selectedItemBuilder,
    this.height,
    this.width,
    this.hint,
    this.hintFontSize,
    this.hintColor,
    this.backgroundColor,
    this.dropDownBackgroundColor,
    this.boxShadow,
    this.radius,
    this.border,
    this.padding,
    this.customButton,
    this.enabledBoxDecoration = true,
    this.dropdownStyleData,
    this.initItem,
    this.searchMatchFn,
    this.searchHintText,
    this.errorText,
    this.validator,
    this.iconStyleData,

    // chip mode
    this.chipMode = false,
    this.chipItems = const [],
    this.chipBuilder,
    this.onChipRemoved,

    //label
    this.labelText,
    this.labelTextSize,
    this.labelPaddingBottom = 0.0,
    this.labelFontWeight,
    this.labelIsRequired = false,
    this.labelSuffixChild,
    this.labelColor,
    this.labelImage,
  });

  @override
  _CustomDropdownButtonState<T> createState() =>
      _CustomDropdownButtonState<T>();
}

class _CustomDropdownButtonState<T> extends State<CustomDropdownButton<T>> {
  var selectedItem = ValueNotifier<T?>(null);
  final TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    setState(() {
      if (widget.initItem != null) {
        selectedItem.value = widget.initItem;
      }
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// build dropdownItemBuilder list
    List<DropdownItem<T>> items = widget.dataList
        .asMap()
        .entries
        .map<DropdownItem<T>>((entry) {
          int index = entry.key;
          return widget.dropdownItemBuilder(context, index) as DropdownItem<T>;
        })
        .whereType<DropdownItem<T>>()
        .toList();

    /// build selectedItemBuilder list
    List<DropdownMenuItem<T>> selectedItemBuilder = widget.dataList
        .asMap()
        .entries
        .map<DropdownMenuItem<T>>((entry) {
          int index = entry.key;
          return widget.selectedItemBuilder(context, index)
              as DropdownMenuItem<T>;
        })
        .whereType<DropdownMenuItem<T>>()
        .toList();

    /// drop down menu widget
    return FormField<T>(
      validator: widget.validator,
      initialValue: widget.initItem,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (FormFieldState<T> state) {
        final String? effectiveErrorText = widget.errorText ?? state.errorText;
        return SizedBox(
          width: widget.width ?? 80.fw,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // label
              Padding(
                padding: EdgeInsets.only(
                  bottom: widget.labelText != null
                      ? 5
                      : widget.labelPaddingBottom,
                ).r,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.labelImage != null) ...[
                      widget.labelImage!,
                      10.widthSpace,
                    ],
                    if (widget.labelText != null)
                      Expanded(
                        child: AppText(
                          widget.labelText ?? "",
                          isRequired: widget.labelIsRequired,
                          fontWeight: widget.labelFontWeight ?? FontWeight.w600,
                          color: widget.labelColor ?? context.color.onSurface,
                          fontSize: widget.labelTextSize ?? kFont12,
                        ),
                      ),
                    if (widget.labelSuffixChild != null)
                      widget.labelSuffixChild!,
                  ],
                ),
              ),

              // dropdown
              Container(
                // constraints: widget.chipMode
                //     ? BoxConstraints(minHeight: widget.height ?? 45.fh)
                //     : BoxConstraints.tightFor(height: widget.height ?? 45.fh),
                width: widget.width ?? 80.fw,
                decoration: BoxDecoration(
                  color: widget.backgroundColor ?? AppColors.whiteColor,
                  border:
                      widget.border ??
                      Border.all(color: AppColors.greyLightColor),
                  borderRadius: BorderRadius.circular(widget.radius ?? 7.0).r,
                  boxShadow: widget.boxShadow,
                ),
                child: widget.dataList.isEmpty
                    ? Center(
                        child: NoDataWidget(
                          iconEnabled: false,
                          padding: const EdgeInsets.symmetric(vertical: 0).r,
                        ),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // dropdown button
                          SizedBox(
                            height: widget.height ?? 45.fh,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2<T>(
                                customButton: widget.customButton,
                                menuItemStyleData: MenuItemStyleData(
                                  padding:
                                      widget.padding ??
                                      const EdgeInsets.symmetric(
                                        horizontal: kHorizontalPadding,
                                      ).r,
                                  selectedMenuItemBuilder: (context, child) {
                                    return child;
                                  },
                                ),
                                hint: AppText(
                                  widget.hint ??
                                      context.tr(AppStrings.pleaseSelectAnItem),
                                  color:
                                      widget.hintColor ??
                                      AppColors.hintColor.wOpacity(0.75),
                                  fontSize: widget.hintFontSize,
                                  isOverflow: true,
                                ),
                                buttonStyleData: ButtonStyleData(
                                  height: widget.chipMode
                                      ? (widget.height ?? 45.fh)
                                      : (widget.height ?? 45.fh),
                                  overlayColor: WidgetStateColor.transparent,
                                ),
                                items: items,
                                onChanged: (value) async {
                                  if (widget.chipMode) {
                                    widget.onChanged(value);
                                    selectedItem.value = null;
                                  } else {
                                    selectedItem.value = value;
                                    widget.onChanged(value);
                                  }
                                  state.didChange(value);
                                },
                                valueListenable: selectedItem,
                                selectedItemBuilder: (BuildContext context) {
                                  return selectedItemBuilder;
                                },
                                isExpanded: true,
                                underline: const SizedBox(),
                                dropdownStyleData:
                                    widget.dropdownStyleData ??
                                    DropdownStyleData(
                                      // Cap the menu height: without it a long
                                      // list grows taller than the space below
                                      // the button and gets repositioned over
                                      // it (covering the field). Capped, it
                                      // stays anchored below and scrolls.
                                      maxHeight: 0.4.sh,
                                      isOverButton: false,
                                      decoration: BoxDecoration(
                                        color:
                                            widget.dropDownBackgroundColor ??
                                            AppColors.whiteColor,
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(
                                            widget.radius ?? 5,
                                          ).r,
                                          bottomRight: Radius.circular(
                                            widget.radius ?? 5,
                                          ).r,
                                        ),
                                      ),
                                    ),

                                // search bar
                                dropdownSearchData: widget.searchMatchFn != null
                                    ? DropdownSearchData(
                                        searchController: textEditingController,
                                        searchBarWidget: Padding(
                                          padding: const EdgeInsets.all(8.0).r,
                                          child: AppTextFormField(
                                            controller: textEditingController,
                                            hintText:
                                                widget.searchHintText ??
                                                context.tr(AppStrings.search),
                                          ),
                                        ),
                                        searchBarWidgetHeight: 60.fh,
                                        searchMatchFn: widget.searchMatchFn,
                                      )
                                    : null,
                                onMenuStateChange: widget.searchMatchFn != null
                                    ? (isOpen) {
                                        if (!isOpen) {
                                          textEditingController.clear();
                                        }
                                      }
                                    : null,
                                iconStyleData:
                                    widget.iconStyleData ??
                                    const IconStyleData(
                                      icon: Icon(
                                        Iconsax.arrow_down_1_copy,
                                        size: 18,
                                      ),
                                      iconEnabledColor: AppColors.greyColor,
                                    ),
                              ),
                            ),
                          ),

                          // chip items inside dropdown box
                          if (widget.chipMode && widget.chipItems.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.fromLTRB(
                                12,
                                12,
                                12,
                                12,
                              ).r,
                              decoration: BoxDecoration(
                                color: AppColors.greyLight2Color,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(
                                    widget.radius ?? 7.0,
                                  ),
                                  bottomRight: Radius.circular(
                                    widget.radius ?? 7.0,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Wrap(
                                      spacing: 6.fw,
                                      runSpacing: 6.fh,
                                      children: widget.chipItems.map((item) {
                                        if (widget.chipBuilder != null) {
                                          return widget.chipBuilder!(
                                            context,
                                            item,
                                          );
                                        }
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ).r,
                                          decoration: BoxDecoration(
                                            color: context.color.primary,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ).r,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              AppText(
                                                item.toString(),
                                                fontSize: kFont12,
                                                color: AppColors.whiteColor,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              if (widget.onChipRemoved !=
                                                  null) ...[
                                                4.widthSpace,
                                                InkWellWrapper(
                                                  onTap: () =>
                                                      widget.onChipRemoved!(
                                                        item,
                                                      ),
                                                  child: Icon(
                                                    Iconsax.close_circle,
                                                    size: 16.r,
                                                    color: AppColors.whiteColor,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
              ),

              // error message
              if (effectiveErrorText != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 3, 18, 0).r,
                  child: AppText(effectiveErrorText, color: AppColors.redColor),
                ),
            ],
          ),
        );
      },
    );
  }
}
