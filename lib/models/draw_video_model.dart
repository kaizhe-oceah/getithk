class DrawVideoModel {
  int? id;
  int? videoCategoryId;
  String? videoCategoryName;
  int? gradeId;
  String? gradeName;
  String? name;
  String? file;
  int fileSize = 0;

  DrawVideoModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    videoCategoryId = json['video_category_id'];
    videoCategoryName = json['video_category_name'];
    gradeId = json['grade_id'];
    gradeName = json['grade_name'];
    name = json['name'];
    file = json['file'];
    fileSize = json['file_size'] ?? 0;
  }

  /// The name in [file]'s URL, e.g. "VVaU4v….mov"; a new video gets a new
  /// one.
  String? get fileName => Uri.tryParse(file ?? '')?.pathSegments.lastOrNull;
}
