// Package imports:
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

// Project imports:
import '../../imports.dart';

class AppPhoneFormField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isDense;
  final double verticalPadding;
  final double horizontalPadding;
  final int minLines;
  final int maxLines;
  final int? maxLength;
  final int errorMaxLines;
  final TextInputType? textInputType;
  final List<TextInputFormatter>? textInputFormatter;
  final Color? hintTextColor;
  final Color? textColor;
  final Color? labelColor;
  final bool shouldShowVisiblity;
  final Function()? onVisibilityTap;
  final bool enabled;
  final double? hinTextLetterSpacing;
  final Function(PhoneNumber)? onChanged;
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
  final Color? unfocusBorderColor;
  final AutovalidateMode? autovalidateMode;
  final List<String>? countries;
  final PhoneNumber initPhoneNumber;
  final bool enabledClearText;
  final double? spaceBetweenSelectorAndTextField;
  final bool enabledPhoneOtp;
  final GlobalKey<FormState>? formKey;
  final Function(bool) onChecking;
  final PhoneInputSelectorType phoneInputSelectorType =
      PhoneInputSelectorType.DIALOG;

  const AppPhoneFormField({
    super.key,
    required this.initPhoneNumber,
    required this.onChecking,
    this.focusNode,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.isDense = true,
    this.verticalPadding = 13,
    this.horizontalPadding = 5,
    this.minLines = 1,
    this.maxLines = 1,
    this.maxLength,
    this.errorMaxLines = 2,
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
    this.textSize,
    this.labelTextSize,
    this.labelPaddingBottom = 0.0,
    this.errorTextSize = kFont13,
    this.borderColor,
    this.focusBorderColor,
    this.unfocusBorderColor,
    this.autovalidateMode,
    this.countries,
    this.enabledClearText = true,
    this.spaceBetweenSelectorAndTextField,
    this.enabledPhoneOtp = false,
    this.formKey,
  });

  @override
  State<AppPhoneFormField> createState() => _AppPhoneFormFieldState();
}

class _AppPhoneFormFieldState extends State<AppPhoneFormField> {
  int resentIn = 60;
  int resentInOriginal = 60;
  Timer? timer;
  bool canResentNow = true;
  bool isPhoneValid = true;
  late FocusNode _focusNode;
  late TextEditingController _textController;
  late final ThemeData _dialogTheme;
  late final TextStyle _textModeTextStyle;
  late final TextStyle _hintTextStyle;
  // ignore: unused_field
  PhoneNumber? _number;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _textController = widget.controller ?? TextEditingController();

    _textModeTextStyle = TextStyle(
      color: AppColors.blackColor,
      fontSize: kFont13.sp,
      fontWeight: FontWeight.normal,
    );
    _dialogTheme = ThemeData(
      useMaterial3: false,
    ).copyWith(canvasColor: AppColors.whiteColor);
    _hintTextStyle = _textModeTextStyle.copyWith(
      color: AppColors.hintColor.wOpacity(0.7),
    );

    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted && !_focusNode.hasFocus) {
      _focusNode.unfocus();
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // label
        if (widget.labelText != null)
          Padding(
            padding: EdgeInsets.only(
              bottom: widget.labelText != null ? 5 : widget.labelPaddingBottom,
            ).r,
            child: AppText(
              widget.labelText ?? "",
              isRequired: widget.labelIsRequired,
              fontWeight: widget.labelFontWeight ?? FontWeight.w600,
              color: widget.labelColor ?? context.color.onSurface,
              fontSize: widget.labelTextSize,
            ),
          ),

        // textformfield
        phone(context),

        // error message
        if (!isPhoneValid)
          Padding(
            padding: const EdgeInsets.only(top: 3, left: 20).r,
            child: AppText(
              context.tr(AppStrings.invalidMobileNumber),
              color: AppColors.toastErrorColor,
            ),
          ),
      ],
    );
  }

  // phone widget
  Widget phone(BuildContext context) {
    final List<Widget> suffixChildren = [];

    /// Clear Text Button
    if (widget.enabledClearText && _textController.text.isNotEmpty) {
      suffixChildren.add(
        InkWellWrapper(
          onTap: () {
            _textController.clear();
            isPhoneValid = false;
            widget.onChecking(isPhoneValid);
            setState(() {});
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8).r,
            child: Icon(
              MdiIcons.closeCircle,
              size: 18.r,
              color: AppColors.greyColor,
            ),
          ),
        ),
      );
    }

    /// Custom Suffix Icon
    if (widget.suffixIcon != null) {
      suffixChildren.add(widget.suffixIcon!);
    }

    /// Phone OTP Button
    if (widget.enabledPhoneOtp) {
      suffixChildren.add(
        Container(
          color: Colors.white,
          child: InkWellWrapper(
            onTap: () {
              if (widget.formKey != null &&
                  widget.formKey!.currentState!.validate()) {
                if (isPhoneValid) {
                  _focusNode.unfocus();
                  actionResendCode();
                }
              } else {
                printLog("Formkey is missing");
              }
              setState(() {});
            },
            child: AppText(
              textAlign: TextAlign.end,
              canResentNow ? context.tr(AppStrings.sendCode) : "$resentIn",
              color: context.color.primary,
            ),
          ),
        ),
      );
    }

    /// Spacing (only if something else exists)
    if (suffixChildren.isNotEmpty) {
      suffixChildren.add(10.widthSpace);
    }

    return TapRegion(
      onTapUpInside: (tap) {
        _focusNode.requestFocus();
        setState(() {});
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal:
              widget.horizontalPadding +
              (widget.phoneInputSelectorType == PhoneInputSelectorType.DIALOG
                  ? 10
                  : 0),
        ).copyWith(right: 0).r,
        decoration: BoxDecoration(
          color: widget.enabled
              ? AppColors.whiteColor
              : AppColors.greyLightColor,
          borderRadius: BorderRadius.circular(10).r,
          border: Border.all(
            color: !isPhoneValid
                ? AppColors.toastErrorColor
                : (_focusNode.hasFocus
                      ? widget.focusBorderColor ?? context.color.primary
                      : widget.unfocusBorderColor ?? AppColors.greyLightColor),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Theme(
                data: _dialogTheme,
                child: InternationalPhoneNumberInput(
                  // cursorColor: AppColors.of(context).primaryText(),
                  isEnabled: widget.enabled,
                  focusNode: _focusNode,
                  onInputChanged: (val) {
                    if (widget.onChanged != null) {
                      widget.onChanged!(val);
                    }

                    _number = val;
                    setState(() {});
                  },
                  onInputValidated: (bool value) {
                    isPhoneValid = value;
                    widget.onChecking(isPhoneValid);
                    printLog("isPhoneValid: $value");
                  },
                  onSaved: (PhoneNumber number) {
                    printLog("On Saved: $number");
                  },
                  countries:
                      widget.countries ??
                      [
                        "MY", // Malaysia
                      ],
                  // ??
                  //     const [
                  //       "MY", // Malaysia
                  //       "AU", // Australia
                  //       "BD", // Bangladesh
                  //       "BN", // Brunei
                  //       "KH", // Cambodia
                  //       "CA", // Canada
                  //       "CN", // China
                  //       "EG", // Egypt
                  //       "DE", // Germany
                  //       "HK", // Hong Kong
                  //       "IN", // India
                  //       "ID", // Indonesia
                  //       "IR", // Iran
                  //       "JP", // Japan
                  //       "NZ", // New Zealand
                  //       "NO", // Norway
                  //       "PH", // Philippines
                  //       "SA", // Saudi Arabia
                  //       "SG", // Singapore
                  //       "ZA", // South Africa
                  //       "KR", // South Korea
                  //       "LK", // Sri Lanka
                  //       "TW", // Taiwan
                  //       "TZ", // Tanzania
                  //       "TH", // Thailand
                  //       "TL", // Timor Leste
                  //       "US", // United States
                  //       "VN", // Vietnam
                  //     ]
                  selectorConfig: SelectorConfig(
                    selectorType: widget.phoneInputSelectorType,
                    trailingSpace: false,
                  ),
                  searchBoxDecoration: InputDecoration(
                    hoverColor: Colors.transparent,
                    hintText: context.tr(AppStrings.search),
                    hintStyle: _hintTextStyle,
                  ),
                  inputDecoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: widget.hintText,
                    hintStyle: _hintTextStyle,
                    errorStyle: const TextStyle(height: 0),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: widget.verticalPadding,
                    ).r,
                  ),
                  validator: (value) {
                    printLog("Phone validator: $value");

                    setState(() {
                      if (value != null) {
                        if (value.isEmpty) {
                          isPhoneValid = false;
                        }
                      }
                    });

                    return null;
                  },
                  selectorTextStyle: _textModeTextStyle,
                  initialValue: widget.initPhoneNumber,
                  textFieldController: _textController,
                  formatInput: false,
                  spaceBetweenSelectorAndTextField:
                      widget.spaceBetweenSelectorAndTextField ?? 0,
                  textStyle: _textModeTextStyle,
                  errorMessage: null,
                ),
              ),
            ),

            // suffix
            if (suffixChildren.isNotEmpty)
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: suffixChildren,
              ),
          ],
        ),
      ),
    );
  }

  /// Phone OTP
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
    if (!isPhoneValid) return;
    if (!canResentNow) return;

    // await ApiService.api.phoneSendOtp(
    //   showLoader: true,
    //   phoneNo: _number?.phoneNumber?.replaceAll("+", "") ?? "",
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
