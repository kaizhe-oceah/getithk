// Project imports:
import '../utils/enums.dart';

class DrawResultModel {
  /// A trial draw's: nothing won is kept, so it can't be shipped or
  /// exchanged.
  bool isTrial = false;
  int drawCount = 0;
  int? highestGrade;
  List<DrawHistoryModel> drawHistories = [];
  double totalDrawPoint = 0;
  int remainingDraws = 0;
  int totalDraws = 0;
  int? userRemainingDraws;
  bool isAvailable = false;

  DrawResultModel.fromJson(Map<String, dynamic> json) {
    isTrial = json['is_trial'] == true;
    drawCount = json['draw_count'] ?? 0;
    highestGrade = json['highest_grade'];
    drawHistories = json['draw_histories'] != null
        ? List.from(
            json['draw_histories'],
          ).map((element) => DrawHistoryModel.fromJson(element)).toList()
        : [];
    // decimals come as strings, e.g. "78.800000"
    totalDrawPoint = double.tryParse(json['total_draw_point'].toString()) ?? 0;
    remainingDraws = json['remaining_draws'] ?? 0;
    totalDraws = json['total_draws'] ?? 0;
    userRemainingDraws = json['user_remaining_draws'];
    isAvailable = json['is_available'] ?? false;
  }
}

class DrawHistoryModel {
  int? id;

  /// "1" for a draw, "trial" for a trial draw.
  String? type;
  DrawSubProductModel? subProduct;
  double drawAmount = 0;
  double amount = 0;
  double point = 0;
  int? userStockId;

  DrawHistoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    // an int (1) from a draw, a string ("trial") from a trial draw
    type = json['type']?.toString();
    subProduct = json['sub_product'] != null
        ? DrawSubProductModel.fromJson(json['sub_product'])
        : null;
    drawAmount = double.tryParse(json['draw_amount'].toString()) ?? 0;
    amount = double.tryParse(json['amount'].toString()) ?? 0;
    point = double.tryParse(json['point'].toString()) ?? 0;
    userStockId = json['user_stock_id'];
  }
}

class DrawSubProductModel {
  int? id;
  String? name;
  String? image;
  String? backgroundImage;
  int? gradeId;
  String? grade;
  bool isDeliveryOnly = false;
  bool isPsa10 = false;

  DrawSubProductModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    backgroundImage = json['background_image'];
    gradeId = json['grade_id'];
    grade = json['grade'];
    // 1: yes, 2: no; a trial draw sends true / false instead
    isDeliveryOnly =
        json['is_delivery_only'] == 1 || json['is_delivery_only'] == true;
    isPsa10 = json['is_psa_10'] == 1 || json['is_psa_10'] == true;
  }

  /// [gradeId] as a grade; [grade] is its name.
  ProductGrade? get productGrade => ProductGrade.fromValue(gradeId);
}
