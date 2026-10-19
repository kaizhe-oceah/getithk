// Project imports:
import 'address_model.dart';
import 'shipping_order_model.dart';

class ShippingOrderDetailModel extends ShippingOrderModel {
  AddressModel? address;

  String? cancelReason;
  String? remark;

  ShippingOrderDetailModel.fromJson(Map<String, dynamic> json)
    : super.fromJson(json) {
    final dynamic detail = json['detail'];
    address = detail is Map
        ? AddressModel.fromJson(Map<String, dynamic>.from(detail))
        : null;
    cancelReason = json['cancel_reason']?.toString();
    remark = json['remark']?.toString();
  }

  ShippingOrderDetailModel.placeholder() : super.placeholder() {
    orderId = '20260101000000';
    address = AddressModel.placeholder();
  }
}
