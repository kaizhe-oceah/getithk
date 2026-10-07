// Project imports:
import '../../imports.dart';

class AppTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final bool? obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isDense;
  final double verticalPadding;
  final double horizontalPadding;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final int errorMaxLines;
  final bool reserveErrorSpace;
  final TextInputType? textInputType;
  final List<TextInputFormatter>? textInputFormatter;
  final Color? hintTextColor;
  final Color? textColor;
  final Color? labelColor;
  final bool shouldShowVisiblity;
  final Function()? onVisibilityTap;
  final bool enabled;
  final double? hinTextLetterSpacing;
  final Function(String)? onChanged;
  final Color? disableFontColor;
  final double labelTextSpacing;
  final FocusNode? focusNode;
  final String? errorText;
  final bool labelIsRequired;
  final double radius;
  final FontWeight? labelFontWeight;
  final double borderWidth;
  final FontWeight? textFontWeight;
  final Function(PointerDownEvent)? onTapOutside;
  final String? Function(String?)? validator;
  final Color? backgroundColor;
  final double? textSize;
  final double? labelTextSize;
  final double labelPaddingBottom;
  final double? errorTextSize;
  final Color? borderColor;
  final Color? focusBorderColor;
  final AutovalidateMode? autovalidateMode;
  final bool enabledClearText;
  final Widget? labelSuffixChild;
  final bool enabledEmailOtp;
  final GlobalKey<FormState>? formKey;
  final Color? obscureTextDisabledColor;
  final Color? obscureTextEnabledColor;
  final Function()? onEditingComplete;
  final Function()? onClearText;
  final TextInputAction? textInputAction;
  final bool maxMinLinesEnabled;
  final bool readOnly;
  final TextAlign textAlign;
  final EdgeInsetsGeometry? outerPadding;
  final ScrollController? scrollController;

  const AppTextFormField({
    super.key,
    this.focusNode,
    this.controller,
    this.labelText,
    this.hintText,
    this.obscureText,
    this.prefixIcon,
    this.suffixIcon,
    this.isDense = true,
    this.verticalPadding = 13,
    this.horizontalPadding = 18,
    this.minLines,
    this.maxLines,
    this.maxLength,
    this.errorMaxLines = 2,
    this.reserveErrorSpace = false,
    this.textInputType = TextInputType.text,
    this.textInputFormatter,
    this.hintTextColor,
    this.textColor,
    this.labelColor,
    this.shouldShowVisiblity = false,
    this.onVisibilityTap,
    this.enabled = true,
    this.hinTextLetterSpacing,
    this.onChanged,
    this.disableFontColor,
    this.labelTextSpacing = 0.0,
    this.errorText,
    this.labelIsRequired = false,
    this.radius = 8,
    this.labelFontWeight,
    this.borderWidth = 1.0,
    this.textFontWeight,
    this.onTapOutside,
    this.validator,
    this.backgroundColor,
    this.textSize = kFont13,
    this.labelTextSize = kFont13,
    this.labelPaddingBottom = 0.0,
    this.errorTextSize = kFont13,
    this.borderColor,
    this.focusBorderColor,
    this.autovalidateMode,
    this.enabledClearText = true,
    this.labelSuffixChild,
    this.enabledEmailOtp = false,
    this.obscureTextDisabledColor,
    this.obscureTextEnabledColor,
    this.formKey,
    this.onEditingComplete,
    this.onClearText,
    this.textInputAction,
    this.maxMinLinesEnabled = false,
    this.readOnly = false,
    this.textAlign = TextAlign.start,
    this.outerPadding,
    this.scrollController,
  });

  @override
  State<AppTextFormField> createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  static void _defaultOnTapOutside(PointerDownEvent _) {}
  static String? _defaultValidator(String? _) => null;

  bool? obscureText;
  int resentIn = 60;
  int resentInOriginal = 60;
  Timer? timer;
  bool canResentNow = true;
  late FocusNode _focusNode;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();

    if (widget.obscureText != null) {
      obscureText = widget.obscureText!;
    }

    _focusNode = widget.focusNode ?? FocusNode();
    _textController = widget.controller ?? TextEditingController();

    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted && !_focusNode.hasFocus) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    _focusNode.removeListener(_onFocusChange);

    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    if (widget.controller == null) {
      _textController.dispose();
    }

    super.dispose();
  }

  void _handleTap() {
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }
    setState(() {});
  }

  OutlineInputBorder _buildBorder(
    Color color,
    double width,
    BorderRadius borderRadius,
  ) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: color, width: width),
      borderRadius: borderRadius,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: widget.readOnly,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // label
          Padding(
            padding: EdgeInsets.only(
              bottom: widget.labelText != null ? 5 : widget.labelPaddingBottom,
            ).r,
            child: Row(
              children: [
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
                if (widget.labelSuffixChild != null) widget.labelSuffixChild!,
              ],
            ),
          ),

          // textformfield
          _buildTextField(context),
        ],
      ),
    );
  }

  Widget _buildTextField(BuildContext context) {
    final List<Widget> suffixChildren = [];

    if (widget.enabledClearText && _textController.text.isNotEmpty) {
      suffixChildren.add(
        InkWellWrapper(
          onTap: () {
            _textController.clear();
            widget.onClearText?.call();
            setState(() {});
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8).r,
            child: Icon(
              Iconsax.close_circle,
              size: 18.r,
              color: AppColors.greyColor,
            ),
          ),
        ),
      );
    }

    if (obscureText != null) {
      suffixChildren.add(
        InkWellWrapper(
          onTap: () {
            obscureText = !obscureText!;
            setState(() {});
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8).r,
            child: Icon(
              obscureText! ? Iconsax.eye_slash_copy : Iconsax.eye_copy,
              color:
                  (obscureText!
                      ? widget.obscureTextDisabledColor
                      : widget.obscureTextEnabledColor ??
                            widget.obscureTextDisabledColor) ??
                  AppColors.blackColor,
              size: 20.r,
            ),
          ),
        ),
      );
    }

    if (widget.suffixIcon != null) {
      suffixChildren.add(widget.suffixIcon!);
    }

    if (widget.enabledEmailOtp) {
      suffixChildren.add(
        InkWellWrapper(
          onTap: () {
            if (widget.formKey?.currentState?.validate() ?? false) {
              actionResendCode();
            } else {
              printLog("Formkey is missing");
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 5).r,
            child: AppText(
              canResentNow ? context.tr(AppStrings.sendCode) : "$resentIn",
              color: context.color.primary,
            ),
          ),
        ),
      );
    }

    if (suffixChildren.isNotEmpty) {
      suffixChildren.add(10.widthSpace);
    }

    final borderRadius = BorderRadius.circular(widget.radius).r;
    final errorStyle = Theme.of(context).textTheme.bodySmall!.merge(
      TextStyle(
        color: AppColors.redColor,
        fontSize: widget.errorTextSize?.sp ?? widget.textSize?.sp ?? kFont13.sp,
      ),
    );
    double errorHeight = 0;
    if (widget.reserveErrorSpace) {
      final painter = TextPainter(
        text: TextSpan(
          text: List.filled(widget.errorMaxLines, ' ').join('\n'),
          style: errorStyle,
        ),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      errorHeight = painter.height;
      painter.dispose();
    }

    // Keep the same subtext height before, during and after validation.
    Widget errorSlot(String message) => SizedBox(
      height: errorHeight,
      child: widget.errorMaxLines == 1
          ? FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                message,
                style: errorStyle,
                maxLines: 1,
                softWrap: false,
              ),
            )
          : Text(message, style: errorStyle, maxLines: widget.errorMaxLines),
    );

    return Container(
      padding: widget.outerPadding,
      child: TextFormField(
        textAlign: widget.textAlign,
        onTapOutside: widget.onTapOutside ?? _defaultOnTapOutside,
        onTap: _handleTap,
        readOnly: widget.readOnly,
        textInputAction: widget.textInputAction,
        onEditingComplete: widget.onEditingComplete,
        enabled: widget.enabled,
        controller: _textController,
        focusNode: _focusNode,
        scrollController: widget.scrollController,
        obscureText: obscureText ?? false,
        maxLines: widget.maxLines ?? 1,
        minLines: widget.minLines ?? 1,
        maxLength: widget.maxLength,
        autovalidateMode:
            widget.autovalidateMode ?? AutovalidateMode.onUserInteraction,
        keyboardType: widget.textInputType,
        inputFormatters: widget.textInputFormatter ?? const [],
        style: TextStyle(
          color: widget.textColor ?? AppColors.blackColor,
          fontSize: widget.textSize?.sp,
          fontWeight: widget.textFontWeight,
        ),
        onChanged: (val) {
          widget.onChanged?.call(val);
          setState(() {});
        },
        decoration: InputDecoration(
          // color
          fillColor: widget.enabled
              ? (widget.backgroundColor ?? AppColors.whiteColor)
              : AppColors.greyLightColor.wOpacity(0.7),
          filled: true,
          hoverColor: Colors.transparent,

          // error
          helper: widget.reserveErrorSpace ? errorSlot(' ') : null,
          errorMaxLines: widget.errorMaxLines,
          errorStyle: TextStyle(
            color: AppColors.redColor,
            fontSize:
                widget.errorTextSize?.sp ?? widget.textSize?.sp ?? kFont13.sp,
          ),
          errorBorder: _buildBorder(
            AppColors.redColor,
            widget.borderWidth,
            borderRadius,
          ),
          focusedErrorBorder: _buildBorder(
            AppColors.redColor,
            widget.borderWidth,
            borderRadius,
          ),

          // normal border
          enabledBorder: _buildBorder(
            widget.borderColor ?? AppColors.greyLightColor,
            widget.borderWidth,
            borderRadius,
          ),
          focusedBorder: _buildBorder(
            widget.focusBorderColor ?? context.color.primary,
            widget.borderWidth,
            borderRadius,
          ),
          disabledBorder: _buildBorder(
            widget.borderColor ?? AppColors.greyLightColor,
            0,
            borderRadius,
          ),

          // hint
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: widget.hintTextColor ?? AppColors.hintColor.wOpacity(0.7),
            fontSize: widget.textSize?.sp ?? kFont13.sp,
            letterSpacing: widget.hinTextLetterSpacing ?? 0,
          ),

          // prefix
          prefixIcon: widget.prefixIcon,
          prefixIconConstraints: const BoxConstraints(
            minWidth: 2,
            minHeight: 2,
          ),

          // suffix
          suffixIcon: suffixChildren.isNotEmpty
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: suffixChildren,
                )
              : null,

          // content padding
          contentPadding: EdgeInsets.symmetric(
            horizontal: widget.horizontalPadding,
            vertical: widget.verticalPadding,
          ).r,

          // dense
          isDense: widget.isDense,
        ),
        validator: widget.validator ?? _defaultValidator,
        errorBuilder: widget.reserveErrorSpace
            ? (context, message) => errorSlot(message)
            : null,
      ),
    );
  }

  /// Email OTP
  /// Timer Functions

  void startResentCountDown() {
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) => setState(() {
        if (resentIn < 2) {
          allowResent();
        } else {
          resentIn = resentIn - 1;
        }
      }),
    );
  }

  void allowResent() {
    canResentNow = true;
    timer!.cancel();
  }

  void actionResendCode() async {
    if (!canResentNow) return;

    // await ApiService.api.emailSendOtp(
    //   showLoader: true,
    //   email: _textController.text,
    //   onSuccess: (_) {
    //     resetTimer();
    //   },
    // );
  }

  void resetTimer() {
    resentIn = resentInOriginal;
    canResentNow = false;
    startResentCountDown();
    setState(() {});
  }
}
