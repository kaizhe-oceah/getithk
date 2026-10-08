// Project imports:
import '../../imports.dart';

/// The search box of the bottom sheets (tag filter, phone country): a grey
/// rounded [AppTextFormField] with a search icon and no border.
class AppSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const AppSearchField({
    required this.controller,
    required this.hintText,
    super.key,
  });

  static const Color _background = Color(0xFFF2F4F7);
  static const Color _hintColor = Color(0xFFA3AFBF);

  @override
  Widget build(BuildContext context) {
    return AppTextFormField(
      controller: controller,
      hintText: hintText,
      hintTextColor: _hintColor,
      textColor: AppColors.loginTextColor,
      backgroundColor: _background,
      borderColor: AppColors.transparentColor,
      focusBorderColor: AppColors.transparentColor,
      radius: 10,
      textInputAction: TextInputAction.search,
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 14, right: 8).r,
        child: Icon(
          Iconsax.search_normal_1_copy,
          size: 18.r,
          color: _hintColor,
        ),
      ),
    );
  }
}
