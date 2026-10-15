// Project imports:
import '../imports.dart';
import '../models/address_model.dart';
import '../models/shipping_address_form_model.dart';
import '../models/shipping_country_model.dart';

class AddAddressController extends ChangeNotifier {
  BuildContext context = NavigationService.context;
  bool _isDisposed = false;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// True while the countries load; the country field shows a skeleton.
  bool isLoading = true;

  /// True while the picked country's form loads; its fields show a skeleton.
  bool isFormLoading = true;

  List<ShippingCountryModel> countries = [];

  /// The picked country; the first one until another is picked.
  ShippingCountryModel? country;

  /// The picked country's form; null if it didn't load.
  ShippingAddressFormModel? form;

  /// The typed fields' text, by field key.
  Map<String, TextEditingController> textControllers = {};

  /// The select fields' picked option values, by field key.
  Map<String, String?> selectValues = {};

  /// The address being edited; null when adding one.
  final AddressModel? address;

  /// 設為預設地址; ticked to start with for the player's first address, or
  /// as [address] has it.
  bool isDefault;

  /// Whether [address]'s values went into its country's form yet; only the
  /// first time it loads.
  bool _isPrefilled = false;

  AddAddressController({this.address, bool isDefault = false})
    : isDefault = address?.isDefault ?? isDefault {
    _load();
  }

  bool get isEdit => address != null;

  /// A field's value: a select's picked option value, a typed field's text.
  String? _value(ShippingAddressFieldModel field) => field.isSelect
      ? selectValues[field.key]
      : textControllers[field.key]?.text.trim();

  /// The create API's `values`: each of the form's fields, in its order and
  /// by its key, then the form's dial code as `phone_code`.
  Map<String, dynamic> get values => {
    for (final ShippingAddressFieldModel field in form?.fields ?? [])
      field.key: _value(field),
    'phone_code': ?form?.dialCode,
  };

  static const List<String> _nameKeys = ['last_name', 'first_name'];

  /// The update API's `name`, as the listing words it ("lam Kai"): the last
  /// name, then the first; [address]'s own for a form without them.
  String get _name {
    final String name = _nameKeys
        .map((key) => textControllers[key]?.text.trim() ?? '')
        .where((element) => element.isNotEmpty)
        .join(' ');
    return name.isNotEmpty ? name : (address?.name ?? '');
  }

  /// The update API's `address`, as the listing words it: the form's other
  /// fields (not the names or the phone) in its order, blanks skipped.
  String get _addressLine => [
    for (final ShippingAddressFieldModel field in form?.fields ?? [])
      if (!_nameKeys.contains(field.key) && !field.isPhone) _value(field) ?? '',
  ].where((element) => element.isNotEmpty).join(', ');

  String? get _phoneNo =>
      form?.fields.where((element) => element.isPhone).map(_value).firstOrNull;

  Future<void> _load() async {
    await ApiService.api.getShippingCountryList(
      onSuccess: (response) =>
          countries = ShippingCountryModel.listFromJson(response.data),
    );

    // editing: the address's own country
    country =
        countries
            .where(
              (element) =>
                  element.shippingCountryId == address?.shippingCountryId,
            )
            .firstOrNull ??
        countries.firstOrNull;
    isLoading = false;
    update();
    await _loadForm();
  }

  /// The picked country's form; what's typed into a field the new form also
  /// has (a name, the phone number) is kept.
  Future<void> _loadForm() async {
    final int? id = country?.shippingCountryId;
    if (id == null) {
      isFormLoading = false;
      update();
      return;
    }

    isFormLoading = true;
    update();

    ShippingAddressFormModel? loaded;
    await ApiService.api.getShippingAddressForm(
      shippingCountryId: id,
      onSuccess: (response) {
        if (response.data is Map) {
          loaded = ShippingAddressFormModel.fromJson(
            Map<String, dynamic>.from(response.data),
          );
        }
      },
    );

    // another country was picked meanwhile; its own load takes over
    if (_isDisposed || id != country?.shippingCountryId) return;

    form = loaded;
    _resetValues();
    _prefill();
    isFormLoading = false;
    update();
  }

  /// [address]'s saved values (its `fields`, by key) into its country's
  /// form, the first time that form loads.
  void _prefill() {
    final AddressModel? address = this.address;
    if (address == null ||
        _isPrefilled ||
        form?.shippingCountryId != address.shippingCountryId) {
      return;
    }
    _isPrefilled = true;

    for (final ShippingAddressFieldModel field in form?.fields ?? []) {
      final String? value = address.fields[field.key]?.toString();
      if (!field.isSelect) {
        textControllers[field.key]?.text = value ?? '';
      } else if (field.options.any((element) => element.value == value)) {
        selectValues[field.key] = value;
      }
    }
  }

  /// A controller per typed field and a value per select of [form], keeping
  /// those of the same key from the last form.
  void _resetValues() {
    final List<ShippingAddressFieldModel> fields = form?.fields ?? [];

    final Map<String, TextEditingController> controllers = {
      for (final ShippingAddressFieldModel field in fields)
        if (!field.isSelect)
          field.key:
              textControllers.remove(field.key) ?? TextEditingController(),
    };
    // the fields using them are gone (the skeleton shows while loading)
    for (final TextEditingController controller in textControllers.values) {
      controller.dispose();
    }
    textControllers = controllers;

    selectValues = {
      for (final ShippingAddressFieldModel field in fields)
        if (field.isSelect)
          field.key:
              field.options.any(
                (element) => element.value == selectValues[field.key],
              )
              ? selectValues[field.key]
              : null,
    };
  }

  void onSelectCountry(ShippingCountryModel? value) {
    if (value == null || value == country) return;

    country = value;
    _loadForm();
  }

  void onSelectOption(String key, String? value) => selectValues[key] = value;

  void onToggleDefault() {
    isDefault = !isDefault;
    update();
  }

  /// Saves the address (updates [address] when editing), then back to the
  /// list with true so it refreshes.
  Future<void> onConfirm() async {
    final int? countryId = form?.shippingCountryId;
    if (isFormLoading || countryId == null) return;
    if (!(formKey.currentState?.validate() ?? false)) return;

    FocusManager.instance.primaryFocus?.unfocus();

    void onSuccess(ApiResponseModel response) {
      response.showMessage();
      AppNavigator.pop(context, true);
    }

    final int? addressId = address?.shippingAddressId;
    if (addressId != null) {
      await ApiService.api.updateShippingAddress(
        showLoader: false,
        shippingAddressId: addressId,
        name: _name,
        phoneCode: form?.dialCode,
        phoneNo: _phoneNo,
        address: _addressLine,
        isDefault: isDefault,
        shippingCountryId: countryId,
        values: values,
        onSuccess: onSuccess,
      );
    } else {
      await ApiService.api.createShippingAddress(
        showLoader: false,
        shippingCountryId: countryId,
        isDefault: isDefault,
        values: values,
        onSuccess: onSuccess,
      );
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    for (final TextEditingController controller in textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void update() {
    if (!_isDisposed) notifyListeners();
  }
}
