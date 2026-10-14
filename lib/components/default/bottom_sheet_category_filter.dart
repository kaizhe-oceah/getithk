// Project imports:
import '../../imports.dart';
import '../../models/category_model.dart';

class BottomSheetCategoryFilter extends StatefulWidget {
  final CategoryModel? selected;
  final ValueChanged<CategoryModel?> onConfirm;

  const BottomSheetCategoryFilter({
    required this.selected,
    required this.onConfirm,
    super.key,
  });

  @override
  State<BottomSheetCategoryFilter> createState() =>
      _BottomSheetCategoryFilterState();
}

class _BottomSheetCategoryFilterState extends State<BottomSheetCategoryFilter> {
  static List<CategoryModel>? _cachedCategories;

  List<CategoryModel>? _categories = _cachedCategories;

  /// The picked category's id; null: every category.
  late int? _selectedId = widget.selected?.id;

  static const Color _plainBorder = Color(0xFFDCE3EC);
  static const Color _plainText = Color(0xFFA3AFBF);
  static const Color _resetColor = Color(0xFFF0F2F5);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await ApiService.api.getProductCategories(
      onSuccess: (response) =>
          _cachedCategories = CategoryModel.listFromJson(response.data),
    );

    if (mounted) setState(() => _categories = _cachedCategories ?? []);
  }

  /// Clears the filter right away: every category, and the sheet closes.
  void _onReset() {
    AppNavigator.pop(context);
    widget.onConfirm(null);
  }

  void _onConfirm() {
    AppNavigator.pop(context);
    widget.onConfirm(
      _categories?.where((e) => e.id == _selectedId).firstOrNull,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16).r,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(),
            14.heightSpace,
            Flexible(child: SingleChildScrollView(child: _categoryChips())),
            20.heightSpace,
            _buttons(),
          ],
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
            context.tr(AppStrings.filter),
            fontSize: kFont16,
            fontWeight: FontWeight.w700,
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

  Widget _categoryChips() {
    final List<CategoryModel>? categories = _categories;

    if (categories == null) {
      return SizedBox(
        height: 80.r,
        child: const Center(
          child: CircularProgressIndicatorWidget(size: 32, showText: false),
        ),
      );
    }

    if (categories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20).r,
        child: AppText(
          context.tr(AppStrings.noDataFound),
          fontSize: kFont13,
          color: _plainText,
          textAlign: TextAlign.center,
        ),
      );
    }

    return Wrap(
      spacing: 8.r,
      runSpacing: 8.r,
      children: [
        for (final CategoryModel category in categories)
          _categoryChip(category),
      ],
    );
  }

  /// A category as a pill: plain grey until picked, then primary on a light
  /// tint of it. Tapping the picked one unpicks it.
  Widget _categoryChip(CategoryModel category) {
    final bool selected = category.id == _selectedId;
    final Color primary = context.color.primary;

    return InkWellWrapper(
      onTap: () => setState(() => _selectedId = selected ? null : category.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5).r,
        decoration: BoxDecoration(
          color: selected ? primary.wOpacity(0.1) : AppColors.whiteColor,
          border: Border.all(
            color: selected ? primary : _plainBorder,
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        // one weight either way, so picking a category doesn't widen it
        child: AppText(
          category.name ?? '',
          fontSize: kFont12,
          fontWeight: FontWeight.w500,
          color: selected ? primary : _plainText,
        ),
      ),
    );
  }

  /// 重設 (grey) and 確定篩選 (primary), side by side.
  Widget _buttons() {
    final EdgeInsets padding = const EdgeInsets.symmetric(vertical: 13).r;

    return Row(
      children: [
        Expanded(
          child: AppButtonWidget(
            text: context.tr(AppStrings.reset),
            radius: 10,
            textSize: kFont14,
            buttonColor: _resetColor,
            textColor: AppColors.loginTextColor,
            padding: padding,
            onTap: _onReset,
          ),
        ),
        12.widthSpace,
        Expanded(
          child: AppButtonWidget(
            text: context.tr(AppStrings.confirmFilter),
            radius: 10,
            textSize: kFont14,
            textColor: AppColors.whiteColor,
            padding: padding,
            onTap: _onConfirm,
          ),
        ),
      ],
    );
  }
}
