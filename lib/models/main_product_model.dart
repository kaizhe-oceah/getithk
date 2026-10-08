// Flutter imports:
import 'package:flutter/painting.dart';

// Project imports:
import '../utils/parser.dart';

class MainProductModel {
  int? id;
  String? name;
  String? image;
  String? description;
  int? categoryId;
  String? categoryName;
  int? modeId;
  String? modeName;
  int? sorting;
  int? status;
  int? drawAmountType;
  double drawAmount = 0;
  int totalDraws = 0;
  int remainingDraws = 0;
  int totalSold = 0;
  int? userRemainingDraws;
  bool isTrialDraw = false;
  bool isNewUsersOnly = false;
  bool isAvailable = false;
  bool isSoldOut = false;
  double? topupPerDraw;
  double? currentTopupAmount;
  double? topupToNextUnlock;
  int? unlockedDraws;
  int? availableDraws;
  int? maxUnlockTimes;
  int? remainingUnlockedDraws;
  List<MainProductTagModel> tags = [];
  int? videoCategoryId;
  List<MainProductGradeVideoModel> gradeVideos = [];

  MainProductModel.fromJson(Map<String, dynamic> json) {
    id = int.tryParse('${json['id']}');
    name = json['name']?.toString();
    image = json['image']?.toString();
    description = json['description']?.toString();
    categoryId = int.tryParse('${json['category_id']}');
    categoryName = json['category_name']?.toString();
    modeId = int.tryParse('${json['mode_id']}');
    modeName = json['mode_name']?.toString();
    sorting = int.tryParse('${json['sorting']}');
    status = int.tryParse('${json['status']}');
    drawAmountType = int.tryParse('${json['draw_amount_type']}');
    drawAmount = parseDouble(json['draw_amount']);
    totalDraws = parseInt(json['total_draws']);
    remainingDraws = parseInt(json['remaining_draws']);
    totalSold = parseInt(json['total_sold']);
    userRemainingDraws = int.tryParse('${json['user_remaining_draws']}');
    isTrialDraw = parseBool(json['is_trial_draw']);
    isNewUsersOnly = parseBool(json['is_new_users_only']);
    isAvailable = parseBool(json['is_available']);
    isSoldOut = parseBool(json['is_sold_out']);
    topupPerDraw = double.tryParse('${json['topup_per_draw']}');
    currentTopupAmount = double.tryParse('${json['current_topup_amount']}');
    topupToNextUnlock = double.tryParse('${json['topup_to_next_unlock']}');
    unlockedDraws = int.tryParse('${json['unlocked_draws']}');
    availableDraws = int.tryParse('${json['available_draws']}');
    maxUnlockTimes = int.tryParse('${json['max_unlock_times']}');
    remainingUnlockedDraws = int.tryParse(
      '${json['remaining_unlocked_draws']}',
    );
    tags = MainProductTagModel.listFromJson(json['tags']);
    videoCategoryId = int.tryParse('${json['video_category_id']}');
    gradeVideos = MainProductGradeVideoModel.listFromJson(json['grade_videos']);
  }

  /// Whether topping up unlocks draws (the 每儲值 … 可抽 1 次 box).
  bool get hasTopupUnlock => topupPerDraw != null;

  /// Whether the draw button works.
  bool get canDraw => isAvailable && !isSoldOut;

  /// The products in an API list; anything that isn't one is skipped.
  static List<MainProductModel> listFromJson(dynamic data) => data is List
      ? [
          for (final item in data)
            if (item is Map)
              MainProductModel.fromJson(Map<String, dynamic>.from(item)),
        ]
      : [];
}

class MainProductTagModel {
  String? name;
  String? color;

  MainProductTagModel.fromJson(Map<String, dynamic> json) {
    name = json['name']?.toString();
    color = json['color']?.toString();
  }

  Color? get colorValue => parseHexColor(color);

  static List<MainProductTagModel> listFromJson(dynamic data) => data is List
      ? [
          for (final item in data)
            if (item is Map)
              MainProductTagModel.fromJson(Map<String, dynamic>.from(item)),
        ]
      : [];
}

class MainProductGradeVideoModel {
  int? gradeId;
  List<int> videoIds = [];

  MainProductGradeVideoModel.fromJson(Map<String, dynamic> json) {
    gradeId = int.tryParse('${json['grade_id']}');
    videoIds = parseListInt(json['video_ids']);
  }

  static List<MainProductGradeVideoModel> listFromJson(dynamic data) =>
      data is List
      ? [
          for (final item in data)
            if (item is Map)
              MainProductGradeVideoModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
        ]
      : [];
}
