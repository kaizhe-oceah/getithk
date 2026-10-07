/// A promo banner under the carousel, from the page-banner API.
class PageBannerModel {
  /// Which promo it is, e.g. "invite_point", "accumulate_box", "voucher".
  String? key;
  String? image;

  PageBannerModel.fromJson(Map<String, dynamic> json) {
    key = json['key']?.toString();
    image = json['image']?.toString();
  }

  /// The banners in an API `data` list; anything that isn't one is skipped.
  static List<PageBannerModel> listFromJson(dynamic data) => data is List
      ? [
          for (final item in data)
            if (item is Map)
              PageBannerModel.fromJson(Map<String, dynamic>.from(item)),
        ]
      : [];
}
