// Project imports:
import '../utils/parser.dart';

/// A prize in a main product, from the sub-product-listing API: [name] at
/// grade [gradeName] (一等獎, 二等獎, …), worth [amount] pts.
class SubProductModel {
  int? id;
  int? mainProductId;
  String? name;
  String? image;
  int? gradeId;
  String? gradeName;

  /// The chance of drawing it, in percent, e.g. 0.347222.
  double displayPercentage = 0;
  double amount = 0;
  int? quantity;

  /// A PSA 10 graded card (`is_psa_10` is 1; 2 is no).
  bool isPsa10 = false;

  /// Delivery only (`is_delivery_only` is 1; 2 is no).
  bool isDeliveryOnly = false;
  String? backgroundImage;
  List<int> videoIds = [];

  SubProductModel.fromJson(Map<String, dynamic> json) {
    id = int.tryParse('${json['id']}');
    mainProductId = int.tryParse('${json['main_product_id']}');
    name = json['name']?.toString();
    image = json['image']?.toString();
    gradeId = int.tryParse('${json['grade_id']}');
    gradeName = json['grade_name']?.toString();
    displayPercentage = parseDouble(json['display_percentage']);
    amount = parseDouble(json['amount']);
    quantity = int.tryParse('${json['quantity']}');
    isPsa10 = parseInt(json['is_psa_10']) == 1;
    isDeliveryOnly = parseInt(json['is_delivery_only']) == 1;
    backgroundImage = json['background_image']?.toString();
    videoIds = parseListInt(json['video_ids']);
  }

  /// Stand-in values for the page's loading skeleton.
  SubProductModel.placeholder() {
    name = 'Prize name';
    quantity = 1;
    gradeId = 2;
    gradeName = '一等獎';
  }

  /// The prizes in an API list; anything that isn't one is skipped.
  static List<SubProductModel> listFromJson(dynamic data) => data is List
      ? [
          for (final item in data)
            if (item is Map)
              SubProductModel.fromJson(Map<String, dynamic>.from(item)),
        ]
      : [];
}
