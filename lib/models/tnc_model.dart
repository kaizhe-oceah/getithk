/// The terms of service or privacy policy, from the term-condition API.
class TncModel {
  int? id;

  /// [TncType.value]: 1 terms of service, 2 privacy policy.
  int? type;
  String? title;

  /// HTML.
  String? content;

  TncModel.fromJson(Map<String, dynamic> json) {
    id = int.tryParse('${json['id']}');
    type = int.tryParse('${json['type']}');
    title = json['title']?.toString();
    content = json['content']?.toString();
  }
}
