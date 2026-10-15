/// A country an address can be in, from the shipping-country-listing API.
class ShippingCountryModel {
  int? shippingCountryId;

  /// ISO 3166 alpha-2, e.g. "MY".
  String? countryCode;
  String? name;

  ShippingCountryModel.fromJson(Map<String, dynamic> json) {
    shippingCountryId = int.tryParse('${json['shipping_country_id']}');
    countryCode = json['country_code']?.toString().toUpperCase();
    name = json['name']?.toString();
  }

  /// Stand-in values for the page's loading skeleton.
  ShippingCountryModel.placeholder() {
    name = 'Country name';
  }

  /// The countries in an API `data` list; anything that isn't one is skipped.
  static List<ShippingCountryModel> listFromJson(dynamic data) => data is List
      ? [
          for (final item in data)
            if (item is Map)
              ShippingCountryModel.fromJson(Map<String, dynamic>.from(item)),
        ]
      : [];
}
