// Package imports:
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

// Project imports:
import '../../imports.dart';
import '../../models/phone_code_model.dart';
import 'bottom_sheet_phone_country.dart';

/// A phone number field: an [AppTextFormField] with a country button (flag
/// + dial code) at its start, which opens a sheet to pick the country from
/// [phoneCodes] (null: the phone-codes API's, loaded once per run).
///
/// It's a form field: the form's validate() checks the number is there and
/// valid for the picked country (Google's libphonenumber), the error showing
/// under the box.
class AppPhoneFormField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;

  /// The starting country: [PhoneNumber.isoCode] and [PhoneNumber.dialCode].
  final PhoneNumber initPhoneNumber;

  /// The countries to pick from; null: the phone-codes API's.
  final List<PhoneCodeModel>? phoneCodes;

  /// The number with its country ("+60132287524", dial code, ISO code), on
  /// every change.
  final ValueChanged<PhoneNumber>? onChanged;

  /// Whether the number is valid for the picked country, on every change.
  final ValueChanged<bool> onChecking;

  /// Extra checks once the number is there and valid.
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final bool enabled;

  final String? labelText;
  final double? labelTextSize;
  final FontWeight? labelFontWeight;
  final Color? labelColor;
  final String? hintText;
  final Color? hintTextColor;
  final Color? textColor;
  final double? textSize;
  final Color? borderColor;
  final Color? focusBorderColor;
  final double radius;

  /// The box's height; null: [AppTextFormField]'s own.
  final double? height;
  final int errorMaxLines;
  final double? errorTextSize;

  /// Keep a line under the box for the error even when there's none, so
  /// the form doesn't jump when one shows.
  final bool reserveErrorSpace;

  const AppPhoneFormField({
    super.key,
    required this.initPhoneNumber,
    required this.onChecking,
    this.controller,
    this.focusNode,
    this.phoneCodes,
    this.onChanged,
    this.validator,
    this.autovalidateMode,
    this.enabled = true,
    this.labelText,
    this.labelTextSize,
    this.labelFontWeight,
    this.labelColor,
    this.hintText,
    this.hintTextColor,
    this.textColor,
    this.textSize,
    this.borderColor,
    this.focusBorderColor,
    this.radius = kDefaultRadius,
    this.height,
    this.errorMaxLines = 2,
    this.errorTextSize = kFont13,
    this.reserveErrorSpace = false,
  });

  @override
  State<AppPhoneFormField> createState() => _AppPhoneFormFieldState();
}

class _AppPhoneFormFieldState extends State<AppPhoneFormField> {
  /// The phone-codes API's countries, loaded by the first field that needs
  /// them and kept for the run.
  static List<PhoneCodeModel>? _apiPhoneCodes;

  late final TextEditingController _textController =
      widget.controller ?? TextEditingController();
  final GlobalKey<FormFieldState<String>> _fieldKey = GlobalKey();

  late PhoneCodeModel _country = PhoneCodeModel(
    countryCode: widget.initPhoneNumber.isoCode ?? kDefaultPhoneCountry,
    dialCode: widget.initPhoneNumber.dialCode ?? kDefaultPhoneDialCode,
  );

  /// Whether the number is valid for [_country].
  bool _isValid = false;

  /// The text last checked, so cursor moves don't check it again.
  String? _checkedText;

  /// Bumped by every check, so a slower one for older text is dropped.
  int _checks = 0;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    _loadPhoneCodes();
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    if (widget.controller == null) _textController.dispose();
    super.dispose();
  }

  /// [AppPhoneFormField.phoneCodes], else the API's, else (while they load)
  /// just the starting country.
  List<PhoneCodeModel> get _phoneCodes =>
      widget.phoneCodes ?? _apiPhoneCodes ?? [_country];

  Future<void> _loadPhoneCodes() async {
    if (widget.phoneCodes != null || _apiPhoneCodes != null) return;

    await ApiService.api.getPhoneCode(
      onSuccess: (response) {
        final List<PhoneCodeModel> codes = PhoneCodeModel.listFromJson(
          response.data,
        );
        if (codes.isNotEmpty) _apiPhoneCodes = codes;
      },
    );

    if (mounted) setState(() {});
  }

  void _onTextChanged() {
    if (_textController.text == _checkedText) return;
    _checkedText = _textController.text;
    _onNumberChanged();
  }

  void _onCountryPicked(PhoneCodeModel code) {
    if (code.countryCode == _country.countryCode) return;

    setState(() => _country = code);
    _onNumberChanged();
  }

  /// Tells [AppPhoneFormField.onChanged] the number with its country, then
  /// checks it's valid for that country.
  Future<void> _onNumberChanged() async {
    final String countryCode = _country.countryCode ?? '';
    final String dialCode = _country.dialCode ?? '';
    String national = _textController.text.replaceAll(RegExp(r'[^0-9]'), '');
    // a trunk 0 typed before the local number ("0132287524")
    if (national.startsWith('0')) national = national.substring(1);
    final String number = '$dialCode$national';

    widget.onChanged?.call(
      PhoneNumber(
        phoneNumber: number,
        dialCode: dialCode,
        isoCode: countryCode,
      ),
    );

    final int check = ++_checks;
    bool valid = false;
    if (national.isNotEmpty) {
      try {
        valid =
            await PhoneNumber.getPhoneNumberType(number, countryCode) !=
            PhoneNumberType.UNKNOWN;
      } catch (_) {
        // not a number it can parse
      }
    }
    if (!mounted || check != _checks) return;

    _isValid = valid;
    widget.onChecking(valid);

    // an error showing goes as soon as the number is fixed
    final FormFieldState<String>? field = _fieldKey.currentState;
    if (field != null && field.hasError) field.validate();
  }

  /// The form's check: there's a number, valid for the picked country, and
  /// it passes [AppPhoneFormField.validator].
  String? _validate() {
    final String text = _textController.text;

    if (text.replaceAll(RegExp(r'[^0-9]'), '').isEmpty) {
      return context.tr(AppStrings.phoneNumberRequired);
    }
    if (!_isValid) return context.tr(AppStrings.invalidMobileNumber);
    return widget.validator?.call(text);
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      key: _fieldKey,
      autovalidateMode: widget.autovalidateMode ?? AutovalidateMode.disabled,
      validator: (_) => _validate(),
      builder: (field) {
        final Color? errorColor = field.hasError ? AppColors.redColor : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextFormField(
              controller: _textController,
              focusNode: widget.focusNode,
              enabled: widget.enabled,
              textInputType: TextInputType.phone,
              textInputFormatter: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(15),
              ],
              labelText: widget.labelText,
              labelTextSize: widget.labelTextSize ?? kFont13,
              labelFontWeight: widget.labelFontWeight,
              labelColor: widget.labelColor,
              hintText: widget.hintText,
              hintTextColor: widget.hintTextColor,
              textColor: widget.textColor,
              textSize: widget.textSize ?? kFont13,
              radius: widget.radius,
              borderColor: errorColor ?? widget.borderColor,
              focusBorderColor: errorColor ?? widget.focusBorderColor,
              prefixIcon: _countryButton(),
            ),
            _error(field.errorText),
          ],
        );
      },
    );
  }

  /// 🇲🇾 +60 ▾ │ — opens the country sheet when there's more than one.
  Widget _countryButton() {
    final List<PhoneCodeModel> codes = _phoneCodes;
    final bool canPick = widget.enabled && codes.length > 1;

    return InkWellWrapper(
      onTap: canPick
          ? () => BottomSheetHelper.phoneCountry(
              codes: codes,
              selected: _country.countryCode,
              onSelected: _onCountryPicked,
            )
          : null,
      child: SizedBox(
        height: widget.height,
        child: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10).r,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PhoneCountryFlag(countryCode: _country.countryCode, width: 22.r),
              6.widthSpace,
              AppText(
                _country.dialCode ?? '',
                fontSize: widget.textSize ?? kFont13,
                fontWeight: FontWeight.w500,
                color: widget.textColor ?? AppColors.loginTextColor,
              ),
              if (canPick)
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18.r,
                  color: widget.hintTextColor ?? AppColors.greyColor,
                ),
              8.widthSpace,
              Container(
                width: 1,
                height: 20.r,
                color: widget.borderColor ?? AppColors.greyLightColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Under the box: [message], or (with
  /// [AppPhoneFormField.reserveErrorSpace]) an empty line of the same height.
  Widget _error(String? message) {
    if (message == null && !widget.reserveErrorSpace) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 18).r,
      child: AppText(
        message ?? ' ',
        fontSize: widget.errorTextSize,
        color: AppColors.redColor,
        maxLines: widget.errorMaxLines,
        isOverflow: true,
      ),
    );
  }
}
