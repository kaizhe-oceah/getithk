/// A saved shipping address, from the shipping-address-listing API.
class AddressModel {
  int? shippingAddressId;
  int? shippingCountryId;

  /// ISO 3166 alpha-2, e.g. "MY".
  String? countryCode;
  String? countryName;

  /// The recipient, e.g. "lam Kai".
  String? name;

  /// e.g. "+60".
  String? phoneCode;
  String? phoneNo;

  /// The whole address on one line, as the API words it.
  String? address;

  /// The address form's values by field key (first_name, city, …), for
  /// editing it.
  Map<String, dynamic> fields = {};
  bool isDefault = false;

  AddressModel.fromJson(Map<String, dynamic> json) {
    shippingAddressId = int.tryParse('${json['shipping_address_id']}');
    shippingCountryId = int.tryParse('${json['shipping_country_id']}');
    countryCode = json['country_code']?.toString().toUpperCase();
    countryName = json['country_name']?.toString();
    name = json['name']?.toString();
    phoneCode = json['phone_code']?.toString();
    phoneNo = json['phone_no']?.toString();
    address = json['address']?.toString();
    fields = json['fields'] is Map
        ? Map<String, dynamic>.from(json['fields'])
        : {};
    // true or 1: yes
    isDefault = json['is_default'] == true || json['is_default'] == 1;
  }

  /// Stand-in values for the page's loading skeleton.
  AddressModel.placeholder() {
    name = 'Recipient name';
    countryName = 'Country';
    phoneCode = '+60';
    phoneNo = '123456789';
    address = 'Address line for the loading skeleton, City, State';
  }

  /// e.g. "+60 178854580".
  String get phone => '${phoneCode ?? ''} ${phoneNo ?? ''}'.trim();

  /// The addresses in the listing API's `data`: a plain list, or a page of
  /// one under `listing`.
  static List<AddressModel> listFromData(dynamic data) =>
      listFromJson(data is Map ? data['listing'] : data);

  /// The default one of [addresses]; the first if none is.
  static AddressModel? defaultOf(List<AddressModel> addresses) =>
      addresses.where((element) => element.isDefault).firstOrNull ??
      addresses.firstOrNull;

  /// The addresses in an API list; anything that isn't one is skipped.
  static List<AddressModel> listFromJson(dynamic data) => data is List
      ? [
          for (final item in data)
            if (item is Map)
              AddressModel.fromJson(Map<String, dynamic>.from(item)),
        ]
      : [];
}
