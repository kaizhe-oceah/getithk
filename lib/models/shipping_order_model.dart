// Project imports:
import '../utils/enums.dart';
import '../utils/parser.dart';

/// A shipment the player asked for, from the shipping-listing API.
class ShippingOrderModel {
  int? shippingId;

  /// e.g. "20261015000004".
  String? orderId;

  /// In pts.
  double totalAmount = 0;
  double shippingFee = 0;

  String? trackingNo;
  String? sfExpressSmartLockerNumber;
  String? packageTrackingLink;

  ShippingStatus? status;

  /// [status] as the API words it, in the app's language ("待發貨").
  String? statusName;

  /// When it was asked for, and when it reached each status; in UTC.
  DateTime? createdAt;
  DateTime? toShipAt;
  DateTime? toReceiveAt;
  DateTime? completedAt;
  DateTime? cancelledAt;

  List<ShippingOrderItemModel> items = [];

  ShippingOrderModel.fromJson(Map<String, dynamic> json) {
    shippingId = int.tryParse('${json['shipping_id']}');
    orderId = json['order_id']?.toString();
    totalAmount = parseDouble(json['total_amount']);
    shippingFee = parseDouble(json['shipping_fee']);
    trackingNo = json['tracking_no']?.toString();
    sfExpressSmartLockerNumber = json['sf_express_smart_locker_number']
        ?.toString();
    packageTrackingLink = json['package_tracking_link']?.toString();
    status = ShippingStatus.fromValue(int.tryParse('${json['status']}'));
    statusName = json['status_name']?.toString();
    createdAt = DateTime.tryParse('${json['created_at']}');
    toShipAt = DateTime.tryParse('${json['to_ship_at']}');
    toReceiveAt = DateTime.tryParse('${json['to_receive_at']}');
    completedAt = DateTime.tryParse('${json['completed_at']}');
    cancelledAt = DateTime.tryParse('${json['cancelled_at']}');
    items = ShippingOrderItemModel.listFromJson(json['items']);
  }

  /// Stand-in values for the page's loading skeleton.
  ShippingOrderModel.placeholder() {
    status = ShippingStatus.toShip;
    statusName = 'Status';
    createdAt = DateTime.utc(2026);
    shippingFee = 50;
    totalAmount = 500;
    items = [ShippingOrderItemModel.placeholder()];
  }

  /// The orders in an API list; anything that isn't one is skipped.
  static List<ShippingOrderModel> listFromJson(dynamic data) => data is List
      ? [
          for (final item in data)
            if (item is Map)
              ShippingOrderModel.fromJson(Map<String, dynamic>.from(item)),
        ]
      : [];
}

/// A card in a [ShippingOrderModel].
class ShippingOrderItemModel {
  String? subProductName;
  String? image;

  /// Each, in pts.
  double amount = 0;
  int quantity = 0;

  ShippingOrderItemModel.fromJson(Map<String, dynamic> json) {
    subProductName = json['sub_product_name']?.toString();
    image = json['image']?.toString();
    amount = parseDouble(json['amount']);
    quantity = parseInt(json['quantity']);
  }

  ShippingOrderItemModel.placeholder() {
    subProductName = 'Card name for the skeleton';
    amount = 500;
    quantity = 1;
  }

  static List<ShippingOrderItemModel> listFromJson(dynamic data) => data is List
      ? [
          for (final item in data)
            if (item is Map)
              ShippingOrderItemModel.fromJson(Map<String, dynamic>.from(item)),
        ]
      : [];
}
