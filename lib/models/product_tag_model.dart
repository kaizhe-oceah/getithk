// Flutter imports:
import 'package:flutter/painting.dart';

// Project imports:
import '../utils/parser.dart';

/// A product tag from the tag-listing API, for filtering the product list.
class ProductTagModel {
  int? id;
  String? name;

  /// Hex, e.g. "#FF4500".
  String? color;

  ProductTagModel.fromJson(Map<String, dynamic> json) {
    id = int.tryParse('${json['id']}');
    name = json['name']?.toString();
    color = json['color']?.toString();
  }

  /// [color] as a Color; null if it isn't a 6-digit hex.
  Color? get colorValue => parseHexColor(color);

  /// The tags in an API `data` list; anything that isn't one, or has no id,
  /// is skipped.
  static List<ProductTagModel> listFromJson(dynamic data) => data is List
      ? [
          for (final item in data)
            if (item is Map)
              ProductTagModel.fromJson(Map<String, dynamic>.from(item)),
        ].where((e) => e.id != null).toList()
      : [];
}
