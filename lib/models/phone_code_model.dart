/// A country players can sign up / log in with, from the phone-codes API.
class PhoneCodeModel {
  /// ISO 3166 alpha-2, e.g. "HK".
  String? countryCode;

  /// e.g. "+852".
  String? dialCode;

  PhoneCodeModel({this.countryCode, this.dialCode});

  PhoneCodeModel.fromJson(Map<String, dynamic> json) {
    countryCode = json['country_code']?.toString().toUpperCase();
    dialCode = json['dial_code']?.toString();
  }

  /// The codes in an API `data` list; anything that isn't one, or has no
  /// country, is skipped.
  static List<PhoneCodeModel> listFromJson(dynamic data) => data is List
      ? [
          for (final item in data)
            if (item is Map)
              PhoneCodeModel.fromJson(Map<String, dynamic>.from(item)),
        ].where((e) => (e.countryCode ?? '').isNotEmpty).toList()
      : [];
}
