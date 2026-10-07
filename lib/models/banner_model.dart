/// A home carousel banner, from the banner API.
class BannerModel {
  int? id;
  String? title;
  String? image;

  /// Opened when the banner is tapped, if set.
  String? link;

  BannerModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : int.tryParse('${json['id']}');
    title = json['title']?.toString();
    image = json['image']?.toString();
    link = json['link']?.toString();
  }

  /// The banners in an API `data` list; anything that isn't one is skipped.
  static List<BannerModel> listFromJson(dynamic data) => data is List
      ? [
          for (final item in data)
            if (item is Map)
              BannerModel.fromJson(Map<String, dynamic>.from(item)),
        ]
      : [];
}
