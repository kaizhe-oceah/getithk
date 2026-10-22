// Project imports:
import '../utils/enums.dart';
import '../utils/parser.dart';

/// A grade from the grade listing: 尾賞, 一等獎, …
class ProductGradeModel {
  int? id;
  String? name;
  int sortOrder = 0;
  bool isLastOne = false;

  ProductGradeModel.fromJson(Map<String, dynamic> json) {
    id = int.tryParse('${json['id']}');
    name = json['name']?.toString();
    sortOrder = parseInt(json['sort_order']);
    isLastOne = json['is_last_one'] == true;
  }

  ProductGrade? get grade => ProductGrade.fromValue(id);

  static List<ProductGradeModel> listFromJson(dynamic data) => data is List
      ? [
          for (final item in data)
            if (item is Map)
              ProductGradeModel.fromJson(Map<String, dynamic>.from(item)),
        ]
      : [];
}
