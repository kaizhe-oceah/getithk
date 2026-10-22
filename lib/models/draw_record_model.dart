// Project imports:
import '../utils/parser.dart';

/// A prize the player drew, from the draw history (抽獎記錄).
class DrawRecordModel {
  int? id;
  String? image;
  int? drawAmountType;
  double drawAmount = 0;
  double amount = 0;
  double point = 0;
  DateTime? createdAt;
  String? mainProductName;
  String? subProductName;
  String? gradeName;

  // who drew it
  int? levelId;
  String? levelName;
  String? name;
  int? avatarId;
  String? avatarImage;
  int? frameId;
  String? frameImage;
  String? backgroundImage;

  DrawRecordModel.fromJson(Map<String, dynamic> json) {
    id = int.tryParse('${json['id']}');
    image = json['image']?.toString();
    drawAmountType = int.tryParse('${json['draw_amount_type']}');
    drawAmount = parseDouble(json['draw_amount']);
    amount = parseDouble(json['amount']);
    point = parseDouble(json['point']);
    createdAt = DateTime.tryParse('${json['created_at']}');
    mainProductName = json['main_product_name']?.toString();
    subProductName = json['sub_product_name']?.toString();
    gradeName = json['grade_name']?.toString();
    levelId = int.tryParse('${json['level_id']}');
    levelName = json['level_name']?.toString();
    name = json['name']?.toString();
    avatarId = int.tryParse('${json['avatar_id']}');
    avatarImage = json['avatar_image']?.toString();
    frameId = int.tryParse('${json['frame_id']}');
    frameImage = json['frame_image']?.toString();
    backgroundImage = json['background_image']?.toString();
  }

  /// Stands in while the list loads, under its skeleton.
  DrawRecordModel.placeholder() {
    subProductName = 'Pokemon card name';
    gradeName = '一等獎';
    amount = 100;
    createdAt = DateTime(2026);
  }

  static List<DrawRecordModel> listFromJson(dynamic data) => data is List
      ? [
          for (final item in data)
            if (item is Map)
              DrawRecordModel.fromJson(Map<String, dynamic>.from(item)),
        ]
      : [];
}
