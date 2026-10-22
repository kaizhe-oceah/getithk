// Project imports:
import '../utils/enums.dart';
import '../utils/parser.dart';
import 'sub_product_model.dart';

class SellHistoryModel {
  String? orderId;
  int totalItems = 0;
  double totalAmount = 0;
  int? status;
  DateTime? soldAt;
  List<SellHistoryItemModel> products = [];

  SellHistoryModel.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id']?.toString();
    totalItems = parseInt(json['total_items']);
    totalAmount = parseDouble(json['total_amount']);
    status = int.tryParse('${json['status']}');
    soldAt = DateTime.tryParse('${json['sold_at']}');
    products = SellHistoryItemModel.listFromJson(json['products']);
  }

  SellHistoryModel.placeholder() {
    totalItems = 1;
    totalAmount = 100;
    soldAt = DateTime(2026);
    products = [SellHistoryItemModel.placeholder()];
  }

  static List<SellHistoryModel> listFromJson(dynamic data) => data is List
      ? [
          for (final item in data)
            if (item is Map)
              SellHistoryModel.fromJson(Map<String, dynamic>.from(item)),
        ]
      : [];
}

class SellHistoryItemModel {
  int? subProductId;
  String? name;
  String? gradeName;
  double amount = 0;
  int quantity = 0;
  String? image;

  SellHistoryItemModel.fromJson(Map<String, dynamic> json) {
    subProductId = int.tryParse('${json['sub_product_id']}');
    name = json['item_name']?.toString();
    gradeName = json['grade_name']?.toString();
    amount = parseDouble(json['amount']);
    quantity = parseInt(json['quantity']);
    image = json['image']?.toString();
  }

  SellHistoryItemModel.placeholder() {
    quantity = 1;
  }

  ProductGrade? get grade => ProductGrade.fromName(gradeName);

  SubProductModel toSubProduct() => SubProductModel.fromJson({
    'id': subProductId,
    'name': name,
    'image': image,
    'grade_id': grade?.value,
    'grade_name': gradeName,
    'amount': amount,
    'quantity': quantity,
  });

  static List<SellHistoryItemModel> listFromJson(dynamic data) => data is List
      ? [
          for (final item in data)
            if (item is Map)
              SellHistoryItemModel.fromJson(Map<String, dynamic>.from(item)),
        ]
      : [];
}
