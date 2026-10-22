// Project imports:
import '../utils/parser.dart';

/// The topup-commission-listing's totals: what the player's referrals have
/// topped up, and the commission it's earned them.
class TopupCommissionSummaryModel {
  /// The commission earned, all together.
  double totalAmount = 0;
  int totalInvitedUsers = 0;
  int totalTopupUsers = 0;
  int totalTopupCount = 0;
  double totalTopupAmount = 0;

  TopupCommissionSummaryModel.fromJson(Map<String, dynamic> json) {
    totalAmount = parseDouble(json['total_amount']);
    totalInvitedUsers = parseInt(json['total_invited_users']);
    totalTopupUsers = parseInt(json['total_topup_users']);
    totalTopupCount = parseInt(json['total_topup_count']);
    totalTopupAmount = parseDouble(json['total_topup_amount']);
  }

  /// Stand-in values for the page's loading skeleton.
  TopupCommissionSummaryModel.placeholder() {
    totalAmount = 1000;
    totalInvitedUsers = 10;
    totalTopupCount = 10;
  }
}

/// A referral's top up, and the commission it earned the player.
class TopupCommissionModel {
  String? name;
  DateTime? date;
  double topupAmount = 0;

  /// A percentage: 3 is 3%.
  double commissionRate = 0;

  /// The commission earned.
  double amount = 0;

  TopupCommissionModel.fromJson(Map<String, dynamic> json) {
    name = json['name']?.toString();
    date = DateTime.tryParse('${json['date']}');
    topupAmount = parseDouble(json['topup_amount']);
    commissionRate = parseDouble(json['commission_rate']);
    amount = parseDouble(json['amount']);
  }

  /// Stands in while the list loads, under its skeleton.
  TopupCommissionModel.placeholder() {
    name = 'GETITBOXER 000000';
    date = DateTime(2026);
    topupAmount = 100;
    commissionRate = 3;
    amount = 3;
  }

  static List<TopupCommissionModel> listFromJson(dynamic data) => data is List
      ? [
          for (final item in data)
            if (item is Map)
              TopupCommissionModel.fromJson(Map<String, dynamic>.from(item)),
        ]
      : [];
}
