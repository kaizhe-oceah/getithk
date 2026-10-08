// Project imports:
import '../../imports.dart';
import '../../models/product_tag_model.dart';
import '../main_product/product_tag_chip.dart';
import 'app_search_field.dart';

class BottomSheetTagFilter extends StatefulWidget {
  final List<ProductTagModel> selected;
  final ValueChanged<List<ProductTagModel>> onConfirm;

  const BottomSheetTagFilter({
    required this.selected,
    required this.onConfirm,
    super.key,
  });

  @override
  State<BottomSheetTagFilter> createState() => _BottomSheetTagFilterState();
}

class _BottomSheetTagFilterState extends State<BottomSheetTagFilter> {
  static List<ProductTagModel>? _cachedTags;

  List<ProductTagModel>? _tags = _cachedTags;
  /// The picked tags by id.
  late final Map<int, ProductTagModel> _selected = {
    for (final ProductTagModel tag in widget.selected) tag.id!: tag,
  };
  final TextEditingController _searchController = TextEditingController();

  static const Color _chipTextColor = Color(0xFFA3AFBF);
  static const Color _resetColor = Color(0xFFF0F2F5);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await ApiService.api.getProductTagListing(
      onSuccess: (response) =>
          _cachedTags = ProductTagModel.listFromJson(response.data),
    );

    if (mounted) setState(() => _tags = _cachedTags ?? []);
  }

  void _onToggle(ProductTagModel tag) => setState(
    () => _selected.containsKey(tag.id)
        ? _selected.remove(tag.id)
        : _selected[tag.id!] = tag,
  );

  /// Clears the filter right away: no tags, and the sheet closes.
  void _onReset() {
    AppNavigator.pop(context);
    widget.onConfirm([]);
  }

  void _onConfirm() {
    AppNavigator.pop(context);
    widget.onConfirm(
      _selected.values.toList()..sort((a, b) => a.id!.compareTo(b.id!)),
    );
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
              12.heightSpace,
              _searchField(),
              14.heightSpace,
              Flexible(
                child: SingleChildScrollView(
                  // room for the picked chips' shadows
                  padding: const EdgeInsets.symmetric(vertical: 4).r,
                  child: _tagChips(),
                ),
              ),
              20.heightSpace,
              _buttons(),
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

  Widget _searchField() {
    return AppSearchField(
      controller: _searchController,
      hintText: context.tr(AppStrings.searchTags),
    );
  }

  Widget _tagChips() {
    final List<ProductTagModel>? tags = _tags;

    if (tags == null) {
      return SizedBox(
        height: 80.r,
        child: const Center(
          child: CircularProgressIndicatorWidget(size: 32, showText: false),
        ),
      );
    }

    final String query = _searchController.text.trim().toLowerCase();
    final List<ProductTagModel> shown = [
      for (final ProductTagModel tag in tags)
        if ((tag.name ?? '').toLowerCase().contains(query)) tag,
    ];

    if (shown.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20).r,
        child: AppText(
          context.tr(AppStrings.noDataFound),
          fontSize: kFont13,
          color: _chipTextColor,
          textAlign: TextAlign.center,
        ),
      );
    }

    return Wrap(
      spacing: 8.r,
      runSpacing: 8.r,
      children: [
        for (final ProductTagModel tag in shown)
          ProductTagChip(
            tag: tag,
            selected: _selected.containsKey(tag.id),
            onTap: () => _onToggle(tag),
          ),
      ],
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
