// Project imports:
import '../imports.dart';

class SocialAccountModel {
  final SocialProvider provider;
  bool linked = false;
  String? email;
  DateTime? linkedAt;
  DateTime? lastUsedAt;

  SocialAccountModel(this.provider);

  SocialAccountModel.fromJson(this.provider, Map<String, dynamic> json) {
    linked = parseBool(json['linked']);
    email = json['email']?.toString();
    linkedAt = DateTime.tryParse('${json['linked_at']}');
    lastUsedAt = DateTime.tryParse('${json['last_used_at']}');
  }

  // skips providers the app doesn't know
  static List<SocialAccountModel> listFromJson(dynamic data) {
    if (data is! List) return [];

    final List<SocialAccountModel> accounts = [];
    for (final item in data) {
      if (item is! Map) continue;

      final SocialProvider? provider = SocialProvider.values
          .where((element) => element.value == item['provider'])
          .firstOrNull;
      if (provider == null) continue;

      accounts.add(
        SocialAccountModel.fromJson(provider, Map<String, dynamic>.from(item)),
      );
    }
    return accounts;
  }
}
