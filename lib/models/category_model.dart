/// A product category, from the category-listing API. [image] is its logo
/// or title artwork (about 2.7 : 1).
class CategoryModel {
  int? id;
  String? name;
  String? image;

  CategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : int.tryParse('${json['id']}');
    name = json['name']?.toString();
    image = json['image']?.toString();
  }

  /// The categories in an API `data` list; anything that isn't one is skipped.
  static List<CategoryModel> listFromJson(dynamic data) => data is List
      ? [
          for (final item in data)
            if (item is Map)
              CategoryModel.fromJson(Map<String, dynamic>.from(item)),
        ]
      : [];
}
