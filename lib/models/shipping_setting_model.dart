// Project imports:
import '../utils/parser.dart';

/// What shipping costs, from the shipping-setting API.
class ShippingSettingModel {
  /// The fee, in pts.
  double shippingFee = 0;

  /// The cards' total (pts) from which shipping is free; null: never free.
  double? freeShippingThreshold;

  ShippingSettingModel.fromJson(Map<String, dynamic> json) {
    shippingFee = parseDouble(json['shipping_fee']);
    final double threshold = parseDouble(json['free_shipping_threshold']);
    freeShippingThreshold = threshold > 0 ? threshold : null;
  }
}
