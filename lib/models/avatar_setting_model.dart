// Project imports:
import '../utils/parser.dart';

/// The avatar-setting: the player's name, avatar and frame now, and the
/// avatars and frames to pick from.
class AvatarSettingModel {
  String? name;
  int? avatarId;
  String? avatarImage;
  int? frameId;
  String? frameImage;
  List<AvatarModel> avatars = [];
  List<AvatarFrameModel> frames = [];

  AvatarSettingModel.fromJson(Map<String, dynamic> json) {
    final dynamic user = json['user'];
    if (user is Map) {
      name = user['name']?.toString();
      avatarId = int.tryParse('${user['avatar_id']}');
      avatarImage = user['avatar_image']?.toString();
      frameId = int.tryParse('${user['frame_id']}');
      frameImage = user['frame_image']?.toString();
    }
    avatars = AvatarModel.listFromJson(json['avatars']);
    frames = AvatarFrameModel.listFromJson(json['frames']);
  }

  /// Stand-in values for the page's loading skeleton.
  AvatarSettingModel.placeholder() {
    name = 'GETITBOXER 000000';
    avatars = [for (int i = 0; i < 15; i++) AvatarModel.fromJson({})];
  }
}

class AvatarModel {
  int? id;
  String? name;
  String? image;

  AvatarModel.fromJson(Map<String, dynamic> json) {
    id = int.tryParse('${json['id']}');
    name = json['name']?.toString();
    image = json['image']?.toString();
  }

  static List<AvatarModel> listFromJson(dynamic data) => data is List
      ? [
          for (final item in data)
            if (item is Map)
              AvatarModel.fromJson(Map<String, dynamic>.from(item)),
        ]
      : [];
}

/// A frame around the avatar; locked till the player reaches
/// [minLevelId].
class AvatarFrameModel {
  int? id;
  String? name;
  String? image;
  int? minLevelId;
  bool isLocked = false;

  AvatarFrameModel.fromJson(Map<String, dynamic> json) {
    id = int.tryParse('${json['id']}');
    name = json['name']?.toString();
    image = json['image']?.toString();
    minLevelId = int.tryParse('${json['min_level_id']}');
    isLocked = parseBool(json['is_locked']);
  }

  static List<AvatarFrameModel> listFromJson(dynamic data) => data is List
      ? [
          for (final item in data)
            if (item is Map)
              AvatarFrameModel.fromJson(Map<String, dynamic>.from(item)),
        ]
      : [];
}
