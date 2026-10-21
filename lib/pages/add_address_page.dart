// Dart imports:
import 'dart:math' as math;

// Project imports:
import '../components/backpack/backpack_stock_card.dart';
import '../components/default/bottom_sheet_phone_country.dart';
import '../controllers/add_address_controller.dart';
import '../imports.dart';
import '../models/address_model.dart';
import '../models/shipping_address_form_model.dart';
import '../models/shipping_country_model.dart';

class AddAddressPage extends StatelessWidget {
  /// The address to edit; null to add one.
  final AddressModel? address;
  final bool isDefault;

  const AddAddressPage({this.address, this.isDefault = false, super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          AddAddressController(address: address, isDefault: isDefault),
      child: AppScaffold.basic(
        backgroundColor: AppColors.whiteColor,
        forceOverlayStyle: SystemUiOverlayStyle.dark,
        headerWidgets: [
          AppBarWidget(
            text: context.tr(
              address != null
                  ? AppStrings.editShippingAddress
                  : AppStrings.newShippingAddress,
            ),
            centerTitle: true,
            backgroundColor: AppColors.whiteColor,
            leading: const AppBarBackButton(),
          ),
        ],
        child: Consumer<AddAddressController>(
          builder: (context, controller, _) => _content(context, controller),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, AddAddressController controller) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              kHorizontalPadding,
              12,
              kHorizontalPadding,
              20,
            ).r,
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _countryField(context, controller),
                  16.heightSpace,
                  _fields(context, controller),
                  8.heightSpace,
                  _defaultCheckBox(context, controller),
                ],
              ),
            ),
          ),
        ),
        _confirmBar(context, controller),
      ],
    );
  }

  double get _fieldHeight => math.max(kMinInteractiveDimension, 48.r);

  EdgeInsets get _dropdownPadding =>
      const EdgeInsets.only(left: 12, right: 12).r;

  Widget _countryField(BuildContext context, AddAddressController controller) {
    final bool placeholder = controller.isLoading;
    final List<ShippingCountryModel> countries = placeholder
        ? [ShippingCountryModel.placeholder()]
        : controller.countries;

    return AppSkeletonizer(
      enabled: placeholder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5).r,
            child: AppText(
              context.tr(AppStrings.countryRegion),
              fontSize: kFont13,
              fontWeight: FontWeight.w500,
              color: AppColors.loginTextColor,
            ),
          ),
          AppDropdown<ShippingCountryModel>(
            items: countries,
            value: placeholder ? countries.first : controller.country,
            onChanged: controller.onSelectCountry,
            itemBuilder: (context, country, color) => _countryLabel(country),
            width: double.infinity,
            height: _fieldHeight - 2,
            itemHeight: _fieldHeight,
            radius: 12,
            padding: _dropdownPadding,
            borderColor: AppColors.greyLightColor,
            foregroundColor: AppColors.greyColor,
            iconSize: 18.r,
            tintSelected: false,
          ),
        ],
      ),
    );
  }

  Widget _countryLabel(ShippingCountryModel country) {
    return _dropdownLabel(
      PhoneCountryFlag(countryCode: country.countryCode, width: 18.r),
      country.name,
    );
  }

  Widget _dropdownLabel(Widget leading, String? text) {
    return Row(
      children: [
        SizedBox(
          width: 26.r,
          child: Align(alignment: Alignment.centerLeft, child: leading),
        ),
        Expanded(
          child: AppText(
            text ?? '',
            color: AppColors.loginTextColor,
            maxLines: 1,
            isOverflow: true,
          ),
        ),
      ],
    );
  }

  Widget _fields(BuildContext context, AddAddressController controller) {
    final bool placeholder = controller.isFormLoading;
    final ShippingAddressFormModel? form = placeholder
        ? ShippingAddressFormModel.placeholder()
        : controller.form;
    if (form == null) return const NoDataWidget();

    Widget field(ShippingAddressFieldModel field) =>
        _field(context, controller, field, placeholder: placeholder);

    final List<ShippingAddressFieldModel> fields = form.fields;
    final List<Widget> rows = [];
    for (int index = 0; index < fields.length; index++) {
      final ShippingAddressFieldModel current = fields[index];
      final ShippingAddressFieldModel? next = fields.elementAtOrNull(index + 1);

      if (!current.isHalf) {
        rows.add(field(current));
      } else if (next != null && next.isHalf) {
        rows.add(_pair(field(current), field(next)));
        index++;
      } else {
        rows.add(_pair(field(current), const SizedBox.shrink()));
      }
    }

    return AppSkeletonizer(
      enabled: placeholder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows,
      ),
    );
  }

  Widget _pair(Widget start, Widget end) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: start),
        12.widthSpace,
        Expanded(child: end),
      ],
    );
  }

  Widget _field(
    BuildContext context,
    AddAddressController controller,
    ShippingAddressFieldModel field, {
    required bool placeholder,
  }) {
    final String? remark = field.remark;
    final String? note = field.note;
    final bool hasNotes = remark != null || note != null;
    final Key? key = placeholder
        ? null
        : ValueKey('${controller.form?.shippingCountryId}-${field.key}');

    final Widget input = field.isSelect
        ? _selectField(context, controller, field, key: key)
        : _textField(
            context,
            controller,
            field,
            key: key,
            reserveErrorSpace: !hasNotes,
          );
    if (!field.isSelect && !hasNotes) return input;

    return Padding(
      padding: EdgeInsets.only(bottom: 20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          input,
          if (remark != null) ...[
            6.heightSpace,
            AppText(remark, fontSize: kFont12, color: AppColors.loginHintColor),
          ],
          if (note != null) ...[6.heightSpace, _note(note)],
        ],
      ),
    );
  }

  /// The note on a grey chip as wide as its text; a long one wraps within
  /// the field's width (half a row for a half field).
  Widget _note(String text) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4).r,
        decoration: BoxDecoration(
          color: AppColors.greyBackgroundColor,
          borderRadius: BorderRadius.circular(6).r,
        ),
        child: AppText(
          text,
          fontSize: kFont12,
          color: AppColors.loginHintColor,
        ),
      ),
    );
  }

  IconData _fieldIcon(ShippingAddressFieldModel field) => switch (field.key) {
    'first_name' || 'last_name' => Iconsax.user_copy,
    _ when field.isPhone => Iconsax.call_copy,
    _ when field.isSelect => Iconsax.map_copy,
    _ when field.isNumber => Iconsax.hashtag_copy,
    _ => Iconsax.location_copy,
  };

  String? Function(String?) _validator(
    BuildContext context,
    ShippingAddressFieldModel field,
  ) {
    return (value) {
      final String text = (value ?? '').trim();
      final int? maxLength = field.maxLength;

      if (text.isEmpty) {
        return field.isRequired ? context.tr(AppStrings.cantBeEmpty) : null;
      }
      if (field.isNumber && !AppRegex.digits.hasMatch(text)) {
        return context.tr(AppStrings.numbersOnly);
      }
      if (maxLength != null && text.length > maxLength) {
        return context.tr(AppStrings.maxCharacters, args: ['$maxLength']);
      }
      return null;
    };
  }

  Widget _textField(
    BuildContext context,
    AddAddressController controller,
    ShippingAddressFieldModel field, {
    Key? key,
    bool reserveErrorSpace = true,
  }) {
    final String? dialCode = field.isPhone ? controller.form?.dialCode : null;
    final int? maxLength = field.maxLength;

    return AppTextFormField(
      key: key,
      controller: controller.textControllers[field.key],
      validator: _validator(context, field),
      textInputType: field.isNumber ? TextInputType.number : TextInputType.text,
      textInputFormatter: [
        if (field.isNumber) FilteringTextInputFormatter.digitsOnly,
        if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
      ],
      textInputAction: TextInputAction.next,
      reserveErrorSpace: reserveErrorSpace,
      errorMaxLines: 1,
      errorTextSize: kFont12,
      radius: 12,
      labelFontWeight: FontWeight.w500,
      labelText: field.label ?? '',
      labelIsRequired: field.isRequired,
      labelColor: AppColors.loginTextColor,
      textColor: AppColors.loginTextColor,
      hintText: field.placeholder,
      hintTextColor: AppColors.loginHintColor,
      borderColor: AppColors.greyLightColor,
      prefixIcon: SizedBox(
        height: _fieldHeight,
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 12).r,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _fieldIcon(field),
                size: 14.r,
                color: AppColors.loginHintColor,
              ),
              if (dialCode != null) ...[
                8.widthSpace,
                AppText(dialCode, color: AppColors.loginTextColor),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _selectField(
    BuildContext context,
    AddAddressController controller,
    ShippingAddressFieldModel field, {
    Key? key,
  }) {
    final List<ShippingAddressOptionModel> options = field.options;
    final String? value = controller.selectValues[field.key];
    final ShippingAddressOptionModel? selected = options
        .where((option) => option.value == value)
        .firstOrNull;

    return FormField<ShippingAddressOptionModel>(
      key: key,
      initialValue: selected,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: field.isRequired
          ? (option) =>
                option == null ? context.tr(AppStrings.cantBeEmpty) : null
          : null,
      builder: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (field.label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 5).r,
              child: AppText(
                field.label!,
                isRequired: field.isRequired,
                fontSize: kFont13,
                fontWeight: FontWeight.w500,
                color: AppColors.loginTextColor,
              ),
            ),
          AppDropdown<ShippingAddressOptionModel>(
            items: options,
            value: state.value,
            onChanged: (option) {
              state.didChange(option);
              controller.onSelectOption(field.key, option.value);
            },
            itemBuilder: (context, option, color) =>
                AppText(option.label ?? '', color: AppColors.loginTextColor),
            buttonItemBuilder: (context, option, color) => _dropdownLabel(
              Icon(
                _fieldIcon(field),
                size: 14.r,
                color: AppColors.loginHintColor,
              ),
              option.label,
            ),
            hint: field.placeholder,
            hintColor: AppColors.loginHintColor,
            width: double.infinity,
            height: _fieldHeight - 2,
            itemHeight: _fieldHeight,
            radius: 12,
            padding: _dropdownPadding,
            borderColor: AppColors.greyLightColor,
            foregroundColor: AppColors.greyColor,
            iconSize: 18.r,
            tintSelected: false,
          ),
          if (state.errorText != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 3, 18, 0).r,
              child: AppText(state.errorText!, color: AppColors.redColor),
            ),
        ],
      ),
    );
  }

  Widget _defaultCheckBox(
    BuildContext context,
    AddAddressController controller,
  ) {
    return InkWellWrapper(
      onTap: controller.onToggleDefault,
      child: Row(
        children: [
          BackpackCheckBox(value: controller.isDefault),
          8.widthSpace,
          AppText(
            context.tr(AppStrings.setAsDefaultAddress),
            fontSize: kFont14,
          ),
        ],
      ),
    );
  }

  Widget _confirmBar(BuildContext context, AddAddressController controller) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        kHorizontalPadding.r,
        10.r,
        kHorizontalPadding.r,
        10 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.wOpacity(0.08),
            blurRadius: 8.r,
            offset: Offset(0, -2.r),
          ),
        ],
      ),
      child: AppButtonWidget(
        text: context.tr(
          controller.isEdit ? AppStrings.updateAddress : AppStrings.confirm,
        ),
        radius: 10,
        fontWeight: FontWeight.w600,
        textColor: AppColors.whiteColor,
        gradient: AppColors.brandGradientColor,
        onTap: controller.onConfirm,
      ),
    );
  }
}
