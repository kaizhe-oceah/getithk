// Project imports:
import '../utils/enums.dart';
import 'draw_result_model.dart';

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

  /// One card's [prizes] from a draw, as the backpack holds them: a stock of
  /// as many, each prize's user stock among its ids.
  BackpackModel.fromPrizes(List<DrawHistoryModel> prizes) {
    final DrawSubProductModel? subProduct = prizes.first.subProduct;
    subProductId = subProduct?.id;
    quantity = prizes.length;
    name = subProduct?.name;
    image = subProduct?.image;
    gradeId = subProduct?.gradeId;
    gradeName = subProduct?.grade;
    stockIds = [
      for (final DrawHistoryModel prize in prizes)
        if (prize.userStockId != null) '${prize.userStockId}',
    ];
    amount = prizes.first.amount;
    isDeliveryOnly = subProduct?.isDeliveryOnly ?? false;
    backgroundImage = subProduct?.backgroundImage;
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
