/// The player's level, as `data.level` in the login and profile responses.
class LevelModel {
  int? currentExp;
  int? levelId;
  String? levelName;
  bool isMaxLevel = false;
  String? nextLevelName;
  int? nextLevelRequiredExp;
  int? expToNextLevel;

  LevelModel.fromJson(Map<String, dynamic> json) {
    currentExp = _int(json['current_exp']);
    levelId = _int(json['level_id']);
    levelName = json['level_name']?.toString();
    isMaxLevel = json['is_max_level'] == true;
    nextLevelName = json['next_level_name']?.toString();
    nextLevelRequiredExp = _int(json['next_level_required_exp']);
    expToNextLevel = _int(json['exp_to_next_level']);
  }

  /// How far [currentExp] is towards [nextLevelRequiredExp], from 0 to 1.
  double get progress {
    if (isMaxLevel) return 1;

    final int required = nextLevelRequiredExp ?? 0;
    if (required <= 0) return 0;
    return ((currentExp ?? 0) / required).clamp(0.0, 1.0);
  }

  static int? _int(dynamic value) =>
      value is int ? value : int.tryParse('${value ?? ''}');
}
