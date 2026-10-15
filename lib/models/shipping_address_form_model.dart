/// A country's address form, from the shipping-address-form API: the fields
/// to ask for, in order.
class ShippingAddressFormModel {
  int? shippingCountryId;

  /// ISO 3166 alpha-2, e.g. "MY".
  String? countryCode;

  /// e.g. "+60".
  String? dialCode;
  String? name;
  List<ShippingAddressFieldModel> fields = [];

  ShippingAddressFormModel.fromJson(Map<String, dynamic> json) {
    shippingCountryId = int.tryParse('${json['shipping_country_id']}');
    countryCode = json['country_code']?.toString().toUpperCase();
    dialCode = json['dial_code']?.toString();
    name = json['name']?.toString();
    fields = ShippingAddressFieldModel.listFromJson(json['fields']);
  }

  /// Stand-in fields for the page's loading skeleton.
  ShippingAddressFormModel.placeholder() {
    fields = [
      for (final String size in ['half', 'half', 'full', 'full', 'half'])
        ShippingAddressFieldModel.placeholder(size),
    ];
  }
}

/// One field of a [ShippingAddressFormModel].
class ShippingAddressFieldModel {
  /// The field's name in the add-address request, e.g. "first_name".
  String key = '';
  String? label;

  /// "string", "number" or "select".
  String? type;

  /// "half": beside the half after it; "full": a row of its own.
  String? size;
  bool isRequired = false;

  /// Hint text in the empty field.
  String? placeholder;

  /// Notes to show under the field.
  String? remark;
  String? note;
  int? maxLength;

  /// A select's choices.
  List<ShippingAddressOptionModel> options = [];

  ShippingAddressFieldModel.fromJson(Map<String, dynamic> json) {
    key = json['key']?.toString() ?? '';
    label = json['label']?.toString();
    type = json['type']?.toString();
    size = json['size']?.toString();
    isRequired = json['is_required'] == true || json['is_required'] == 1;
    placeholder = json['placeholder']?.toString();
    remark = json['remark']?.toString();
    note = json['note']?.toString();
    maxLength = int.tryParse('${json['max_length']}');
    options = ShippingAddressOptionModel.listFromJson(json['options']);
  }

  ShippingAddressFieldModel.placeholder(this.size) {
    label = 'Field label';
  }

  bool get isSelect => type == 'select';
  bool get isNumber => type == 'number';
  bool get isHalf => size == 'half';

  /// The phone number, typed without the form's dial code.
  bool get isPhone => key == 'phone_no';

  /// The fields in an API list; anything that isn't one, or has no key, is
  /// skipped.
  static List<ShippingAddressFieldModel> listFromJson(dynamic data) =>
      data is List
      ? [
          for (final item in data)
            if (item is Map)
              ShippingAddressFieldModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
        ].where((element) => element.key.isNotEmpty).toList()
      : [];
}

/// One choice of a select [ShippingAddressFieldModel].
class ShippingAddressOptionModel {
  String? label;

  /// What the add-address request sends for it.
  String? value;

  ShippingAddressOptionModel.fromJson(Map<String, dynamic> json) {
    label = json['label']?.toString();
    value = json['value']?.toString();
  }

  static List<ShippingAddressOptionModel> listFromJson(dynamic data) =>
      data is List
      ? [
          for (final item in data)
            if (item is Map)
              ShippingAddressOptionModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
        ]
      : [];
}
