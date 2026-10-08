// Project imports:
import '../../imports.dart';
import '../../models/phone_code_model.dart';
import 'app_search_field.dart';

/// 選擇國家/地區: the phone field's countries (flag, name, dial code) with a
/// search over them; the current one is highlighted. Picking one closes the
/// sheet and hands it to [onSelected].
class BottomSheetPhoneCountry extends StatefulWidget {
  final List<PhoneCodeModel> codes;

  /// The current country's ISO code.
  final String? selected;
  final ValueChanged<PhoneCodeModel> onSelected;

  const BottomSheetPhoneCountry({
    required this.codes,
    required this.onSelected,
    this.selected,
    super.key,
  });

  @override
  State<BottomSheetPhoneCountry> createState() =>
      _BottomSheetPhoneCountryState();
}

class _BottomSheetPhoneCountryState extends State<BottomSheetPhoneCountry> {
  final TextEditingController _searchController = TextEditingController();

  static const Color _mutedColor = Color(0xFFA3AFBF);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSelect(PhoneCodeModel code) {
    AppNavigator.pop(context);
    widget.onSelected(code);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16).r,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(),
              5.heightSpace,
              AppSearchField(
                controller: _searchController,
                hintText: context.tr(AppStrings.searchCountryRegion),
              ),
              10.heightSpace,
              Flexible(child: _list()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return SizedBox(
      height: 40.r,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AppText(
            context.tr(AppStrings.selectCountryRegion),
            fontSize: kFont16,
            fontWeight: FontWeight.w500,
            color: AppColors.loginTextColor,
          ),
          Positioned(
            right: 0,
            child: InkWellWrapper(
              onTap: () => AppNavigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.all(4).r,
                child: Icon(
                  Icons.close_rounded,
                  size: 22.r,
                  color: AppColors.loginTextColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The countries matching the search, by name, ISO code or dial code.
  Widget _list() {
    final String query = _searchController.text.trim().toLowerCase();
    final List<PhoneCodeModel> shown = [
      for (final PhoneCodeModel code in widget.codes)
        if (query.isEmpty ||
            phoneCountryName(
              context,
              code.countryCode,
            ).toLowerCase().contains(query) ||
            (code.countryCode ?? '').toLowerCase().contains(query) ||
            (code.dialCode ?? '').contains(query))
          code,
    ];

    if (shown.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20).r,
        child: AppText(
          context.tr(AppStrings.noDataFound),
          fontSize: kFont13,
          color: _mutedColor,
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: shown.length,
      separatorBuilder: (_, _) => 4.heightSpace,
      itemBuilder: (context, index) => _row(shown[index]),
    );
  }

  Widget _row(PhoneCodeModel code) {
    final Color primary = context.color.primary;
    final bool selected = code.countryCode == widget.selected;

    return InkWellWrapper(
      onTap: () => _onSelect(code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12).r,
        decoration: BoxDecoration(
          color: selected ? primary.wOpacity(0.06) : AppColors.transparentColor,
          borderRadius: BorderRadius.circular(10).r,
        ),
        child: Row(
          children: [
            PhoneCountryFlag(countryCode: code.countryCode, width: 28.r),
            12.widthSpace,
            Expanded(
              child: AppText(
                phoneCountryName(context, code.countryCode),
                fontSize: kFont14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? primary : AppColors.loginTextColor,
              ),
            ),
            AppText(
              code.dialCode ?? '',
              fontSize: kFont13,
              fontWeight: FontWeight.w500,
              color: selected ? primary : _mutedColor,
            ),
          ],
        ),
      ),
    );
  }
}

String phoneCountryName(BuildContext context, String? countryCode) {
  final String code = countryCode ?? '';
  final String key = 'country_${code.toLowerCase()}';
  final String name = context.tr(key);

  return name == key ? code : name;
}

class PhoneCountryFlag extends StatelessWidget {
  final String? countryCode;
  final double width;

  const PhoneCountryFlag({
    required this.countryCode,
    required this.width,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final double height = width * 0.7;

    return ClipRRect(
      borderRadius: BorderRadius.circular(3).r,
      child: Image.asset(
        'assets/flags/${(countryCode ?? '').toLowerCase()}.png',
        package: 'intl_phone_number_input',
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => SizedBox(width: width, height: height),
      ),
    );
  }
}
