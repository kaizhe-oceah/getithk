// Flutter imports:
import 'package:flutter/painting.dart';
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

  bool isShowQuantity = true;
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
    id = json['id'];
    name = json['name'];
    image = json['image'];
    description = json['description'];
    categoryId = json['category_id'];
    categoryName = json['category_name'];
    modeId = json['mode_id'];
    modeName = json['mode_name'];
    sorting = json['sorting'];
    status = json['status'];
    drawAmountType = json['draw_amount_type'];
    drawAmount = double.tryParse(json['draw_amount'].toString()) ?? 0;
    totalDraws = json['total_draws'] ?? 0;
    remainingDraws = json['remaining_draws'] ?? 0;
    totalSold = int.tryParse(json['total_sold'].toString()) ?? 0;
    userRemainingDraws = json['user_remaining_draws'];
    isTrialDraw = json['is_trial_draw'] ?? false;
    isNewUsersOnly = json['is_new_users_only'] ?? false;
    isAvailable = json['is_available'] ?? false;
    isSoldOut = json['is_sold_out'] ?? false;
    isShowQuantity = json['is_show_quantity'] ?? true;
    topupPerDraw = json['topup_per_draw'] != null
        ? double.tryParse(json['topup_per_draw'].toString())
        : null;
    currentTopupAmount = json['current_topup_amount'] != null
        ? double.tryParse(json['current_topup_amount'].toString())
        : null;
    topupToNextUnlock = json['topup_to_next_unlock'] != null
        ? double.tryParse(json['topup_to_next_unlock'].toString())
        : null;
    unlockedDraws = json['unlocked_draws'];
    availableDraws = json['available_draws'];
    maxUnlockTimes = json['max_unlock_times'];
    remainingUnlockedDraws = json['remaining_unlocked_draws'];
    tags = json['tags'] != null
        ? List.from(
            json['tags'],
          ).map((element) => MainProductTagModel.fromJson(element)).toList()
        : [];
    videoCategoryId = json['video_category_id'];
    gradeVideos = json['grade_videos'] != null
        ? List.from(json['grade_videos'])
              .map((element) => MainProductGradeVideoModel.fromJson(element))
              .toList()
        : [];
  }

  /// A live update (the socket's main-product.update): what it has of what
  /// everyone sees. The player's own (user_remaining_draws, is_available,
  /// the top-up unlock progress) isn't in a public update, so it stays.
  void applyLiveUpdate(Map<String, dynamic> json) {
    final MainProductModel live = MainProductModel.fromJson(json);
    bool has(String key) => json.containsKey(key);

    if (has('name')) name = live.name;
    if (has('image')) image = live.image;
    if (has('description')) description = live.description;
    if (has('category_id')) categoryId = live.categoryId;
    if (has('category_name')) categoryName = live.categoryName;
    if (has('mode_id')) modeId = live.modeId;
    if (has('mode_name')) modeName = live.modeName;
    if (has('sorting')) sorting = live.sorting;
    if (has('status')) status = live.status;
    if (has('draw_amount_type')) drawAmountType = live.drawAmountType;
    if (has('draw_amount')) drawAmount = live.drawAmount;
    if (has('total_draws')) totalDraws = live.totalDraws;
    if (has('remaining_draws')) remainingDraws = live.remainingDraws;
    if (has('total_sold')) totalSold = live.totalSold;
    if (has('is_trial_draw')) isTrialDraw = live.isTrialDraw;
    if (has('is_new_users_only')) isNewUsersOnly = live.isNewUsersOnly;
    if (has('is_sold_out')) isSoldOut = live.isSoldOut;
    if (has('is_show_quantity')) isShowQuantity = live.isShowQuantity;
    if (has('topup_per_draw')) topupPerDraw = live.topupPerDraw;
    if (has('max_unlock_times')) maxUnlockTimes = live.maxUnlockTimes;
    if (has('tags')) tags = live.tags;
    if (has('video_category_id')) videoCategoryId = live.videoCategoryId;
    if (has('grade_videos')) gradeVideos = live.gradeVideos;
  }

  bool get hasTopupUnlock => topupPerDraw != null;
  bool get canDraw => isAvailable && !isSoldOut;
}

class MainProductTagModel {
  String? name;
  String? color;

  MainProductTagModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    color = json['color'];
  }

  Color? get colorValue => parseHexColor(color);
}

class MainProductGradeVideoModel {
  int? gradeId;
  List<int> videoIds = [];

  MainProductGradeVideoModel.fromJson(Map<String, dynamic> json) {
    gradeId = json['grade_id'];
    videoIds = json['video_ids'] != null
        ? List<int>.from(json['video_ids'])
        : [];
  }
}

class MainProductGradeModel {
  int? id;
  int? productGradeId;
  String? gradeName;
  double displayPercentage = 0;
  int sortOrder = 0;
  List<int> videoIds = [];

  MainProductGradeModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productGradeId = json['product_grade_id'];
    gradeName = json['grade_name'];
    displayPercentage =
        double.tryParse(json['display_percentage'].toString()) ?? 0;
    sortOrder = json['sort_order'] ?? 0;
    videoIds = json['video_ids'] != null
        ? List<int>.from(json['video_ids'])
        : [];
  }
}
