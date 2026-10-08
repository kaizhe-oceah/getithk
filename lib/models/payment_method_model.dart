/// A way to pay for a top-up, from the payment-methods API.
class PaymentMethodModel {
  /// e.g. "card", "apple_pay"; identifies the method.
  String? gateway;
  String? name;

  /// Logo URL (PNG or SVG).
  String? icon;

  PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    gateway = json['gateway']?.toString();
    name = json['name']?.toString();
    icon = json['icon']?.toString();
  }

  /// The methods in an API `data` list; anything that isn't one, or has no
  /// gateway, is skipped.
  static List<PaymentMethodModel> listFromJson(dynamic data) => data is List
      ? [
          for (final item in data)
            if (item is Map)
              PaymentMethodModel.fromJson(Map<String, dynamic>.from(item)),
        ].where((e) => (e.gateway ?? '').isNotEmpty).toList()
      : [];

  // the same method (by gateway) across reloads, for the dropdown
  @override
  bool operator ==(Object other) =>
      other is PaymentMethodModel && other.gateway == gateway;

  @override
  int get hashCode => gateway.hashCode;
}
