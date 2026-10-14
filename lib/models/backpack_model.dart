// Project imports:
import '../utils/enums.dart';

class BackpackModel {
  int? subProductId;
  int? productRedeemId;
  int quantity = 0;
  String? name;
  String? image;
  int? gradeId;
  String? gradeName;
  List<String> stockIds = [];
  double amount = 0;
  bool isDeliveryOnly = false;
  String? backgroundImage;

  BackpackModel.fromJson(Map<String, dynamic> json) {
    subProductId = json['sub_product_id'];
    productRedeemId = json['product_redeem_id'];
    quantity = json['quantity'] ?? 0;
    name = json['name'];
    image = json['image'];
    // not in the stock-listing API yet
    gradeId = int.tryParse('${json['grade_id']}');
    gradeName = json['grade_name'];
    stockIds = json['stock_ids'] != null
        ? List.from(
            json['stock_ids'],
          ).map((element) => element.toString()).toList()
        : [];
    amount = double.tryParse(json['amount'].toString()) ?? 0;
    // 1: yes, 2: no
    isDeliveryOnly = json['is_delivery_only'] == 1;
    backgroundImage = json['background_image'];
  }

  /// Stand-in values for the page's loading skeleton.
  BackpackModel.placeholder() {
    // long enough to fill its line, as most names do
    name = 'Card name for the loading skeleton';
    amount = 0.8;
    quantity = 1;
  }

  ProductGrade? get grade => ProductGrade.fromValue(gradeId);

  double get totalAmount => amount * quantity;
}
